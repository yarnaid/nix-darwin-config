{pkgs, ...}: {
  home = {
    username = "yarnaid";
    homeDirectory = "/Users/yarnaid";
    stateVersion = "23.11";
    
    packages = with pkgs; [
    ];

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

    # programs.pyenv = {
    #   enable = true;
    #   enableFishIntegration = true;
    #   enableZshIntegration = true;
    # };

    # Git configuration
    programs.git = {
      enable = true;
      userName = "yarnaid";
      userEmail = "yarnaid@gmail.com";
      
      extraConfig = {
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


  # Configure fish shell through home-manager
  programs.fish = {
    enable = true;
    # useBabelfish = true;
    
    interactiveShellInit = ''
      fish_add_path /run/current-system/sw/bin

      # Source nix environment
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      end
      
      # Source nix-darwin environment
      if test -e /etc/static/bashrc
        fenv source /etc/static/bashrc
      end

      # Fix PATH for nix
      set -gx PATH $HOME/.nix-profile/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin $PATH
      __nixos_path_fix



      # Set environment variables
      set -gx EDITOR nvim
      set -gx LANG en_US.UTF-8
      set -gx LC_ALL en_US.UTF-8
      set -gx LC_CTYPE en_US.UTF-8
      set -U fish_user_paths /opt/homebrew/bin $fish_user_paths
      
      # FZF configuration
      set -gx fzf_preview_file_cmd preview
      set -gx fzf_preview_dir_cmd "eza --all -F --color=always --icons=always --oneline --level=1 --tree"
      set -gx fzf_fd_opts "--hidden --max-depth 5 --exclude .git --exclude node_modules"
      set fzf_diff_highlighter "delta --paging=never --width=20"
      set -gx FZF_CTRL_T_OPTS "--preview 'preview {}' --bind 'tab:down,shift-tab:up'"
      
      # FZF environment variables from .profile
      set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git --exclude node_modules"
      set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
      set -gx FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules"
      set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200' --bind 'tab:down,shift-tab:up'"
      set -gx FZF_DEFAULT_OPTS "--bind 'tab:down,shift-tab:up'"

      # Initialize various tools
      starship init fish | source
      fzf --fish | source
      zox
      ee init fish | source
      set -Ux fifc_editor nvim

      # Homebrew completions
      if test -d (brew --prefix)"/share/fish/completions"
          set -p fish_complete_path (brew --prefix)/share/fish/completions
      end

      if test -d (brew --prefix)"/share/fish/vendor_completions.d"
          set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
      end

      # Pyenv initialization
      # pyenv init - | source
      # pyenv virtualenv-init - | source

      # UV shell completion
      uv generate-shell-completion fish | source
      uvx --generate-shell-completion fish | source

      # Set PAGER from .profile
      set -gx PAGER bat
      # Add nix-darwin binary path
      
      function nvm
        bash -c "source ~/.nvm/nvm.sh; nvm $argv"
      end

      direnv hook fish | source
	
	# pnpm
	set -gx PNPM_HOME "/Users/yarnaid/Library/pnpm"
	if not string match -q -- $PNPM_HOME $PATH
	  set -gx PATH "$PNPM_HOME" $PATH
	end
	# pnpm end

    '';

    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.5";
          sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
      {
        name = "autopair.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "1.0.4";
          sha256 = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
        };
      }
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "master";
          sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
      {
        name = "fifc";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fifc";
          rev = "v0.1.1";
          sha256 = "sha256-p5E4Mx6j8hcM1bDbeftikyhfHxQ+qPDanuM1wNqGm6E=";
        };
      }
      {
        name = "sponge";
        src = pkgs.fetchFromGitHub {
          owner = "meaningful-ooo";
          repo = "sponge";
          rev = "1.1.0";
          sha256 = "sha256-MdcZUDRtNJdiyo2l9o5ma7nAX84xEJbGFhAVhK+Zm1w=";
        };
      }
      {
        name = "preview.fish";
        src = pkgs.fetchFromGitHub {
          owner = "kidonng";
          repo = "preview.fish";
          rev = "master";
          sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
      {
        name = "colored_man_pages.fish";
        src = pkgs.fetchFromGitHub {
          owner = "patrickf1";
          repo = "colored_man_pages.fish";
          rev = "master";
          sha256 = "sha256-ii9gdBPlC1/P1N9xJzqomrkyDqIdTg+iCg0mwNVq2EU=";
        };
      }
      {
        name = "zoxide";
        src = pkgs.fetchFromGitHub {
          owner = "icezyclon";
          repo = "zoxide.fish";
          rev = "3.0";
          sha256 = "sha256-OjrX0d8VjDMxiI5JlJPyu/scTs/fS/f5ehVyhAA/KDM=";
        };
      }
      {
        name = "abbreviation-tips";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-abbreviation-tips";
          rev = "v0.7.0";
          sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
        };
      }
      # {
      #   name = "plugin-foreign-env";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "oh-my-fish";
      #     repo = "plugin-foreign-env";
      #     rev = "master";
      #     sha256 = "sha256-4+k5rSoxkTtYFh/lEjhRkVYa2S4KEzJ/IJbyJl+rJjQ=";
      #   };
      # }
      {
        name = "nvm.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "2.2.17";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-foreign-env";
          rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
          sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
        };
      }
      {
        name = "fzf.fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "v10.3";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM=";
        };
      }
    ];
  };
} 
