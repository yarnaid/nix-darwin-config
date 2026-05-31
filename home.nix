{ pkgs, lib, ... }:
let
  # Same single source of truth as env.nix; here we render the alias files
  # that every shell sources (~/.config/sh/aliases for zsh/fish, .nu for nu).
  shared = builtins.fromTOML (builtins.readFile ./shared.toml);
in
{
  imports = [ ./fish.nix ];
  home = {
    username = "yarnaid";
    homeDirectory = "/Users/yarnaid";
    stateVersion = "25.11";

    packages = with pkgs; [ nodejs_24 ];

    shell.enableShellIntegration = true;

    # Proton Pass CLI — ставится один раз через pnpm-обёртку (postinstall качает
    # официальный бинарь Proton AG с CDN). Идемпотентно: если pass-cli уже в
    # PATH, ничего не делает. Sync между Mac-ами — через Proton-аккаунт после
    # `pass-cli login`. Требует Pass Plus/Family/Professional или Proton-бандл.
    # pnpm (а не npm) — npm install -g пишет в /nix/store (read-only); pnpm
    # пишет в $PNPM_HOME (~/Library/pnpm), который user-writable.
    activation.protonPassCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PNPM_HOME="$HOME/Library/pnpm"
      export PATH="${pkgs.nodejs_24}/bin:/opt/homebrew/bin:$PNPM_HOME/bin:$HOME/.local/bin:$PATH"
      # Check known install locations directly — activation PATH may not match
      # the user's interactive PATH. pnpm 11 layout: $PNPM_HOME/bin/pass-cli.
      if ! [ -x "$PNPM_HOME/bin/pass-cli" ] \
        && ! [ -x "$HOME/.local/bin/pass-cli" ] \
        && ! command -v pass-cli >/dev/null 2>&1; then
        $DRY_RUN_CMD pnpm add -g proton-pass-cli || \
          echo "WARN: proton-pass-cli install failed (offline?). Run manually: pnpm add -g proton-pass-cli"
      fi
    '';

    # Aliases come from shared.toml [aliases], rendered once for every shell.
    # zsh/fish source ~/.config/sh/aliases; nu sources ~/.config/sh/aliases.nu
    # (nu's `alias` is a parse-time keyword and cannot loop-load).
    file.".config/sh/aliases".text =
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "alias ${k}=${lib.escapeShellArg v}") shared.aliases
      )
      + "\n";
    file.".config/sh/aliases.nu".text =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v}") shared.aliases) + "\n";

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "yarnaid";
        email = "yarnaid@gmail.com";
      };
      push.default = "current";
      core = {
        excludesfile = "$HOME/.gitignore_global";
        autocrlf = "input";
        editor = "nvim";
        ignorecase = false;
        pager = "delta";
      };
      interactive.diffFilter = "delta --color-only";
      delta = {
        true-color = "always";
        dark = true;
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      pull = {
        default = "current";
        rebase = false;
      };
      rerere.enabled = 1;
      alias = {
        set-upstream = "!git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`";
      };
      credential = {
        helper = [
          "osxkeychain"
          ""
          "/usr/local/bin/git-credential-manager"
        ];
      };
      "credential \"https://dev.azure.com\"" = {
        useHttpPath = true;
      };
    };
  };

  # Bat configuration
  # bat, btop configs migrated to chezmoi; packages via brew (see brew.nix).

  programs.atuin = {
    enable = true;
    daemon = {
      enable = true;
    };
    settings = {
      theme = {
        name = "tokyo-night";
        enter_accept = true;
      };
      ai = {
        enabled = true;
        capabilities = {
          enable_history_search = true;
          enable_file_tools = true;
          enable_command_execution = true;
        };
        opening = {
          send_cwd = true;
          send_last_command = true;
        };
      };
    };
  };

  # --force kills any leftover daemon and clears stale daemon.sock so
  # launchd KeepAlive recovers cleanly after crashes/reboots. Without this,
  # an orphan socket causes EADDRINUSE on every restart and history stops
  # being recorded silently. home-manager auto-wraps ProgramArguments with
  # `/bin/sh -c "/bin/wait4path /nix/store && exec ..."`, so the bare argv
  # is sufficient.
  launchd.agents.atuin-daemon.config.ProgramArguments = lib.mkForce [
    "${pkgs.atuin}/bin/atuin"
    "daemon"
    "start"
    "--force"
  ];

  programs.direnv = {
    enable = true;
    mise.enable = true;
    stdlib = ''
      # direnv helpers: интеграция Proton Pass CLI с .envrc на проектах.
      #
      # Команды pass-cli (подтверждены `pass-cli --help` на Proton Duo):
      #   login / test / info / inject / run / vault / item / password / totp / ssh-agent / ...
      #
      # Использование в проекте `.envrc`:
      #
      #   use pass                                    # проверить, что pass-cli залогинен
      #
      #   # Вариант A — шаблон → .env (одноразово):
      #   pass_inject .env.tmpl .env                  # .env.tmpl содержит ссылки {{ ... }}
      #
      #   # Вариант B — env только на время процесса (без .env-файла):
      #   #   в shell:  pass run -- python app.py
      #   #   pass-cli сам читает .pass-env / шаблон и инжектит переменные.
      #
      # Pass-ссылки имеют форму, описанную в `pass-cli inject --help` / `pass-cli run --help`.

      use_pass() {
        if ! command -v pass-cli >/dev/null 2>&1; then
          log_error "pass-cli не установлен. См. https://proton.me/pass/download"
          return 1
        fi
        if ! pass-cli test >/dev/null 2>&1; then
          log_error "pass-cli не залогинен. Выполни: pass-cli login"
          return 1
        fi
      }

      # pass_inject <template> [<output>]
      #   Рендерит шаблон через pass-cli inject. Если output не задан — пишет в .env.
      pass_inject() {
        local tmpl="''${1:?usage: pass_inject template [output]}"
        local out="''${2:-.env}"
        if [ ! -f "$tmpl" ]; then
          log_error "pass_inject: шаблон не найден: $tmpl"
          return 1
        fi
        pass-cli inject -i "$tmpl" -o "$out" >/dev/null || {
          log_error "pass-cli inject упал на $tmpl"
          return 1
        }
        # Подгружаем в текущую среду direnv
        dotenv "$out"
        # Перерендериваем, если шаблон поменялся
        watch_file "$tmpl"
      }
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    # useTheme = "night-owl";
    configFile = "$HOME/.config/oh-my-posh.json";
  };

  programs.mise = {
    enable = true;
    globalConfig = {
      min_version = "2024.9.5";
      env = {
        PROJECT_NAME = "{{ config_root | basename }}";
      };
      tools = {
        ruff = "latest";
        uv = "latest";
      };
      settings = {
        experimental = true;
        verbose = false;
        jobs = 16;
        idiomatic_version_file_enable_tools = [ ];
        python.uv_venv_auto = true;
      };
      tasks = {
        install = {
          description = "Install dependencies";
          alias = "i";
          run = "uv pip install -r requirements.txt";
        };
        run = {
          description = "Run the application";
          run = "python app.py";
        };
        test = {
          description = "Run tests";
          run = "pytest tests/";
        };
        lint = {
          description = "Lint the code";
          run = "ruff src/";
        };
      };
    };
  };

  # uv via mise; fastfetch config migrated to chezmoi + brew. uv has no config file.

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nushell = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    antidote = {
      enable = false;
      plugins = [
        # "zsh-users/zsh-autosuggestions"
        # "zsh-users/zsh-completions"
        # "zsh-users/zsh-syntax-highlighting"
      ];
    };
    # autocd = true;
    # defaultKeymap = "viins";
    history = {
      ignoreDups = true;
    };
    # loginExtra = "zellij\n";
    initContent = lib.mkMerge [
      ''
        export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --ansi --preview-window=right:60%:wrap'
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        export BAT_THEME="tokyo-night"
        [ -f "$HOME/.config/sh/aliases" ] && source "$HOME/.config/sh/aliases"
      ''
      # zoxide must initialize last so __zoxide_hook is the final precmd_functions entry
      (lib.mkAfter ''
        eval "$(zoxide init --cmd cd zsh)"
      '')
    ];
    localVariables = {
      ZSH_HIGHLIGHT_HIGHLIGHTERS = "(main brackets)";
      CASE_SENSITIVE = false;
      ENABLE_CORRECTION = true;
    };
  };
  programs.sheldon = {
    enable = true;
    enableFishIntegration = false;
    settings = {
      shell = "zsh";
      plugins = {
        # oh-my-zsh = {
        #   github = "ohmyzsh/ohmyzsh";
        #   dir = "plugins";
        #   use = [
        #     "{aliases,alias-finder,macos,brew,colored-man-pages,command-not-found,golang,git,magic-enter,python,mac-zsh-completions,node,npm,sudo,aws}/*.plugin.zsh"
        #   ];
        # };
        autosuggestions.github = "zsh-users/zsh-autosuggestions";
        completion.github = "zsh-users/zsh-completions";
        mise.github = "wintermi/zsh-mise";
        # fast-syntax-highlighting — sourced last (key sorts last alphabetically
        # in the generated TOML), after autosuggestions/completion as required.
        syntax-highlight.github = "zdharma-continuum/fast-syntax-highlighting";
        # zsh-autocomplete removed: its menu-search/recent-paths ZLE widgets
        # conflict with fast-syntax-highlighting (load-order warnings) and its
        # async worker leaked `command not found: z` (bare zoxide cmd, renamed
        # to `cd` via --cmd cd). atuin + autosuggestions cover its features.
        history-substr-search.github = "zsh-users/zsh-history-substring-search";
        enhancd.github = "b4b4r07/enhancd";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # initialized manually at end of zsh initContent
    options = [
      "--cmd"
      "cd"
    ]; # replace `cd` with zoxide; original is `builtin cd`, interactive is `cdi`
  };
  # zellij, yazi → chezmoi config + brew (yazi `y` wrapper replaced by shared alias).
  programs.intelli-shell = {
    # enable = true;
    enable = false;
  };
  programs.fzf = {
    enable = true;
  };
  # broot, eza, ranger, ruff → chezmoi config + brew (ruff also via mise).
  # eza alias lives in shared.toml; ruff/uv binaries come from mise tools.
  # wezterm: GUI installed via brew cask (see brew.nix); config managed here.
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm'
    local config = wezterm.config_builder()

    -- Plugin: line_time (right-side timestamp gutter, toggled with Cmd+E).
    -- Sourced from the public GitHub repo; wezterm clones it into its
    -- plugin cache (~/Library/Application Support/wezterm/plugins/) on
    -- first launch and reuses it afterwards. Press Cmd+Shift+U to pull
    -- updates without restarting wezterm.
    local line_time = wezterm.plugin.require 'https://github.com/yarnaid/wez_time_line'

    config.font = wezterm.font 'MonoLisa Nerd Font'
    config.font_size = 13.0
    config.color_scheme = 'Afterglow'

    config.initial_cols = 150
    config.initial_rows = 40

    -- Programming ligatures. Defaults are { kern, liga, clig } but some
    -- builds drop them when shaping prompts coloured by escape sequences,
    -- so set them explicitly. calt is required for many MonoLisa ligatures.
    config.harfbuzz_features = {
      'calt=1',
      'clig=1',
      'liga=1',
      'kern=1',
    }

    config.window_background_opacity = 0.8
    config.macos_window_background_blur = 20
    config.window_decorations = 'RESIZE'
    config.hide_tab_bar_if_only_one_tab = true
    config.use_fancy_tab_bar = true
    config.tab_bar_at_bottom = false

    config.scrollback_lines = 1000000
    config.enable_scroll_bar = true

    -- macos-option-as-alt: treat Option as Alt (both sides)
    config.send_composed_key_when_left_alt_is_pressed = false
    config.send_composed_key_when_right_alt_is_pressed = false

    -- Keybindings.
    -- Most "classical Linux" shell shortcuts (Ctrl+A/E/W/U/K/R, Alt+B/F/D,
    -- Alt+Backspace, Alt+.) are readline-level and work automatically once
    -- Option is sent as Alt — handled above by send_composed_key_when_*_alt_is_pressed = false.
    -- Wezterm defaults cover Cmd+C / Cmd+V, Cmd+T / Cmd+W (tabs), Ctrl+Tab cycling,
    -- Cmd+= / Cmd+- zoom, Cmd+F search, etc.
    config.keys = {
      -- Cmd+K: clear scrollback + viewport (macOS Terminal / iTerm2 behaviour).
      -- After clearing, send raw FF (\x0c == Ctrl+L) so the shell redraws the
      -- prompt. Using SendString instead of SendKey { key = 'l', ... } sidesteps
      -- modifier-case ambiguity ('L' would mean Shift+L).
      {
        key = 'k',
        mods = 'CMD',
        action = wezterm.action.Multiple {
          wezterm.action.ClearScrollback 'ScrollbackAndViewport',
          wezterm.action.SendString '\x0c',
        },
      },
      -- Opt+. -> ESC + '.' (M-. in readline) = yank-last-arg in bash/zsh,
      -- history-token-search-backward in fish. Explicit so it works even if
      -- a future config flip changes the alt-as-meta behaviour.
      {
        key = '.',
        mods = 'OPT',
        action = wezterm.action.SendString '\x1b.',
      },
      -- Cmd+P: VS Code-style command palette. Wezterm built-in default is
      -- Ctrl+Shift+P; this adds Cmd+P as an additional binding (the default
      -- remains active since disable_default_key_bindings is left at false).
      {
        key = 'p',
        mods = 'CMD',
        action = wezterm.action.ActivateCommandPalette,
      },
      -- Cmd+Shift+U: refresh all wezterm.plugin sources. Useful during local
      -- plugin development to pick up edits in file://-sourced plugins
      -- without restarting wezterm. (Wezterm default for Ctrl+Shift+U is
      -- CharSelect; that binding stays untouched — different modifier.)
      {
        key = 'u',
        mods = 'CMD|SHIFT',
        action = wezterm.action_callback(function(window)
          wezterm.plugin.update_all()
          window:toast_notification('wezterm', 'plugins reloaded', nil, 2000)
        end),
      },
    }

    -- Copy on select: finalize the selection into both clipboard and primary
    -- on left-mouse release. Three streaks cover drag (1), double-click word
    -- (2) and triple-click line (3). Streak 1 uses CompleteSelectionOrOpenLink*
    -- so single click on a hyperlink still opens it (wezterm default behaviour).
    config.mouse_bindings = {
      {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor 'ClipboardAndPrimarySelection',
      },
      {
        event = { Up = { streak = 2, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
      },
      {
        event = { Up = { streak = 3, button = 'Left' } },
        mods = 'NONE',
        action = wezterm.action.CompleteSelection 'ClipboardAndPrimarySelection',
      },
    }

    -- Inherit working directory on new tabs/panes (OSC 7).
    config.default_cwd = wezterm.home_dir

    -- Apply plugins last so they can extend config.keys and event handlers
    -- without being overwritten by assignments above.
    line_time.apply_to_config(config)

    return config
  '';

  # not available on macOS
  # programs.ghostty = {
  #   enable = true;
  #   # theme = "tokyo-night";
  #   settings = {
  #     font-family = "MonoLiza Nerd Font";
  #     # font-family = Monospace
  #     background-opacity = 0.8;
  #     background-blur = true;
  #     background-blur-radius = 8;
  #     copy-on-select = true;
  #     shell-integration = "detect";
  #     macos-option-as-alt = true;
  #     scrollback-limit = 1000000;
  #     link-previews = true;
  #     working-directory = "inherit";
  #     # keybind = "global:cmd+backquote=toggle_quick_terminal";
  #     quick-terminal-size = "300px,50%";
  #     quick-terminal-screen = "mouse";
  #     quick-terminal-animation-duration = 0.125;
  #     theme = "TokyoNight";
  #   };
  # };
}
