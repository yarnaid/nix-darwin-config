{ pkgs, lib, ... }:
{
  imports = [ ./fish.nix ];
  home = {
    username = "yarnaid";
    homeDirectory = "/Users/yarnaid";
    stateVersion = "25.11";

    packages = with pkgs; [ nodejs_25 ];

    shell.enableShellIntegration = true;

    shellAliases = {
      # git related
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";
      gst = "git status";

      # Vim related
      vim = "nvim";
      v = "nvim";

      # File listing
      ls = "eza --color=always --long --git --icons=always --no-permissions --header --mounts --git-repos --hyperlink";
      l = "ls";
      ll = "ls -la";

      # Navigation
      ".." = "cd ..";

      # Chezmoi
      cv = "chezmoi edit --watch";
      ca = "chezmoi add";
      cu = "chezmoi update";

      # Brew
      b = "brew";
      bs = "brew search --desc --eval-all";
      bi = "brew install";
      bu = "brew upgrade -g";

      # Other tools
      y = "yazi";
      js = "jupyter server";
      os = "ollama serve";

    };

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
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
    };
  };

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
    };
  };

  programs.direnv = {
    enable = true;
    mise.enable = true;
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
        python = "{{ get_env(name='PYTHON_VERSION', default='3.13') }}";
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

  programs.uv = {
    enable = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      theme = "tokyo-night";
    };
  };

  programs.carapace = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
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
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # initialized manually at end of zsh initContent
    options = [
      "--cmd"
      "cd"
    ]; # replace `cd` with zoxide; original is `builtin cd`, interactive is `cdi`
  };
  programs.zellij = {
    enable = true;
  };
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
  programs.intelli-shell = {
    # enable = true;
    enable = false;
  };
  programs.fzf = {
    enable = true;
  };
  programs.broot = {
    enable = true;
  };
  programs.eza = {
    enable = true;
    colors = "auto";
    icons = "auto";
  };
  programs.ranger.enable = true;
  programs.ruff = {
    enable = true;
    settings = {
      line-length = 88;
      indent-width = 4;
      indent-style = "space";
      format = {
        quote-style = "double";
      };
      lint = {
        ignore = [
          "D100"
          "D101"
        ];
      };
    };
  };
  # wezterm: GUI installed via brew cask (see brew.nix); config managed here.
  xdg.configFile."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm'
    local config = wezterm.config_builder()

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
