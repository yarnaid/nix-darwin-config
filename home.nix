{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Same single source of truth as env.nix; here we render the alias files
  # that every shell sources (~/.config/sh/aliases for zsh/fish, .nu for nu).
  shared = builtins.fromTOML (builtins.readFile ./shared.toml);
in
{
  # fish user config moved to chezmoi (~/.config/fish/config.fish + functions +
  # fish_plugins via fisher). System fish env-bridge stays in configuration.nix
  # (programs.fish.enable + useBabelfish → /etc/fish/config.fish).
  imports = [ ];
  home = {
    username = "yarnaid";
    homeDirectory = "/Users/yarnaid";
    stateVersion = "25.11";

    # Shell-integration tools: binaries via nix (on PATH), but their config +
    # shell init live in chezmoi (~/.zshrc etc.). brew-swap of these is a later
    # follow-up; nix keeps the daily-driver shell reliable through the cutover.
    packages = with pkgs; [
      nodejs_24
      atuin
      mise
      direnv
      zoxide
      carapace
      fzf
      sheldon
      oh-my-posh
      nushell
    ];

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

  # Proton Pass CLI as the ssh-agent — serves SSH keys stored in your Proton Pass
  # vault over a unix socket. Defined as a raw launchd agent (not the
  # services.proton-pass-agent module) because that module force-adds its nixpkgs
  # `proton-pass-cli` to home.packages; we want the single pnpm-installed binary
  # (home.activation.protonPassCli above) as the only pass-cli on the box.
  #
  # Cost of the pnpm path: ~/Library/pnpm/bin is mutable and may be absent at the
  # first launchd spawn (before activation's pnpm-install finishes). KeepAlive +
  # the `-x` existence check make the daemon respawn until the binary appears.
  # SSH_AUTH_SOCK is exported session-wide via shared.toml [env] (same socket).
  # One-time setup: `pass-cli login` once — daemon reads creds from the system
  # keychain and respawn-loops until that login exists.
  launchd.agents.proton-pass-agent = {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''p="$HOME/Library/pnpm/bin/pass-cli"; [ -x "$p" ] || p="$HOME/.local/bin/pass-cli"; exec "$p" ssh-agent start --socket-path "$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)/proton-pass-agent"''
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/proton-pass-ssh-agent.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/proton-pass-ssh-agent.err.log";
    };
  };

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

  # atuin: binary via home.packages, config via chezmoi (~/.config/atuin/config.toml,
  # which sets [daemon] enabled = true), init in chezmoi ~/.zshrc. Defined as a
  # raw launchd agent (NOT programs.atuin) — programs.atuin.enable would write its
  # own config.toml and collide with the chezmoi-owned one. With [daemon] enabled,
  # the shell hook records history via the daemon socket: if the daemon is down,
  # new commands are silently dropped, so the agent must be fully self-defined
  # here (a bare ProgramArguments override is inert without programs.atuin to
  # create the agent).
  #
  # `start --force` kills any leftover daemon and clears a stale daemon.sock so
  # launchd KeepAlive recovers cleanly after crashes/reboots; without it an orphan
  # socket causes EADDRINUSE on every restart. home-manager auto-wraps
  # ProgramArguments with `/bin/sh -c "/bin/wait4path /nix/store && exec ..."`,
  # so the bare argv is sufficient.
  launchd.agents.atuin-daemon = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.atuin}/bin/atuin"
        "daemon"
        "start"
        "--force"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/atuin-daemon.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/atuin-daemon.err.log";
    };
  };

  # direnv (+ direnvrc pass-cli helpers), oh-my-posh, mise (config.toml incl.
  # tasks/PROJECT_NAME), carapace: binaries via home.packages, configs via
  # chezmoi, shell init in chezmoi rc. oh-my-posh.json was already a standalone
  # file (not generated). mise config.toml keeps its `{{ }}` mise-template
  # (chezmoi stores it literally).

  # nushell: binary via home.packages; config (config.nu/env.nu) via chezmoi
  # (x-cmd boot dropped). Aliases from shared.toml [aliases] → aliases.nu.

  # zsh (rc + init order), sheldon (plugins → ~/.config/sheldon/zsh.toml),
  # zoxide (--cmd cd): all moved to chezmoi ~/.zshrc. Binaries via home.packages.
  # enhancd loads via sheldon; zoxide inits last so its `cd` wins.
  # zellij, yazi → chezmoi config + brew (yazi `y` wrapper replaced by shared alias).
  programs.intelli-shell = {
    # enable = true;
    enable = false;
  };
  # fzf: binary via home.packages; `fzf --zsh` keybindings init in chezmoi ~/.zshrc.
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
