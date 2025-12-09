{ pkgs, ... }: {
  # imports = [ ./fish.nix ];
  home = {
    username = "yarnaid";
    homeDirectory = "/Users/yarnaid";
    stateVersion = "25.11";

    # packages = with pkgs; [ fishPlugins.foreign-env ];

    shell.enableShellIntegration = true;

    shellAliases = {
      # git related
      g = "git";
      gs = "git status";
      gp = "git push";
      gl = "git pull";

      # Vim related
      vim = "nvim";
      v = "nvim";

      # File listing
      ls =
        "eza --color=always --long --git --icons=always --no-permissions --header --mounts --git-repos --hyperlink";
      l = "ls";
      ll = "ls -la";

      # Navigation
      ".." = "cd ..";
      cd = "z";

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
        set-upstream =
          "!git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`";
      };
      credential = {
        helper = [ "osxkeychain" "" "/usr/local/bin/git-credential-manager" ];
      };
      "credential \"https://dev.azure.com\"" = { useHttpPath = true; };
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
    settings = {
      experimental = true;
      verbose = true;
      jobs = 16;
    };
    globalConfig = {
      min_version = "2024.9.5";
      env = {PROJECT_NAME = "{{ config_root | basename }}";};
      tools = {
        python = "{{ get_env(name='PYTHON_VERSION', default='3.13') }}";
        ruff = "latest";
        uv = "latest";
      };
      settings = {
        idiomatic_version_file_enable_tools = [];
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
    syntaxHighlighting = { enable = true;};
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
    loginExtra = "fastfetch\nzellij\n";
    localVariables = {
      ZSH_HIGHLIGHT_HIGHLIGHTERS = "(main brackets)";
      CASE_SENSITIVE = false;
      ENABLE_CORRECTION = true;
    };
  };
  programs.sheldon = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };
  programs.zellij = {
    enable = true;
  };
  programs.yazi = {
    enable = true;
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
}
