{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # Uninstall all programs not declared
    };
    global = {
      brewfile = true;
      lockfiles = true;
    };
    # Add taps (repositories)
    taps = [
      "acarl005/formulas"
      "domt4/autoupdate"
      "felixkratz/formulae"
      # "homebrew/bundle"
      "homebrew/command-not-found"
      # "homebrew/services"
      "jesseduffield/lazygit"
      "jstkdng/programs"
      "nikitabobko/tap"
    ];
    # Add brews (packages)
    brews = [
      # {
      #   name = "sketchybar";
      #   start_service = false;
      # }
      "deno"
      "swiftlint"
      "bat"
      "tailscale"
      "nvm"
      "podman"
      "podman-compose"
      "bgrep"
      "broot"
      "gnu-sed"
      "btop"
      "chezmoi"
      "hidapi"
      "make"
      "cmake"
      "coreutils"
      "curl"
      "direnv"
      "djvu2pdf"
      "djvulibre"
      "e2fsprogs"
      "entr"
      "exiftool"
      "eza"
      "fastfetch"
      "fd"
      "ffmpeg"
      "ffmpegthumbnailer"
      "fftw"
      # "fish"
      "flac"
      "fmt"
      "fontconfig"
      "fontforge"
      "forgit"
      "freetype"
      "fzf"
      "fzy"
      "gcc"
      "gh"
      "git"
      "git-cal"
      "git-delta"
      "git-extras"
      "git-hooks-go"
      "git-imerge"
      "git-now"
      "git-recent"
      "git-when-merged"
      "glow"
      "gnutls"
      "go"
      "gperf"
      "graphicsmagick"
      "graphviz"
      "hadolint"
      "highlight"
      "howdoi"
      "htop"
      "hyperfine"
      "imagemagick"
      "iperf3"
      "jq"
      "kanata"
      "lame"
      "lazygit"
      "lf"
      "libexif"
      "llvm"
      "lpeg"
      "ls-go"
      "lsd"
      "lua"
      "lua-language-server"
      "luajit"
      "luarocks"
      "lynx"
      "lzo"
      "mas"
      "marksman"
      "miller"
      "mozjpeg"
      "mpg123"
      "mpv"
      "mujs"
      "mupdf"
      "ncdu"
      "neovim"
      "netcat"
      "netpbm"
      "ninja"
      "nlohmann-json"
      "node@22"
      "node-build"
      "nodenv"
      "ouch"
      "p7zip"
      "pandoc"
      "pango"
      "pdftoipe"
      "pillow"
      "pinentry"
      "pinentry-mac"
      "pixman"
      "pkgconf"
      "plantuml"
      "poppler"
      "prettier"
      "procs"
      "pymupdf"
      "pyright"
      "python-lsp-server"
      "python-setuptools"
      "pyenv"
      "ranger"
      "ripgrep"
      "ripgrep-all"
      "rsync"
      "ruff"
      "ruff-lsp"
      "rust"
      "sevenzip"
      "shared-mime-info"
      "smartmontools"
      "snappy"
      "socat"
      "starship"
      "stylua"
      "terminal-notifier"
      "tlrc"
      "tmux"
      "tokei"
      "tree"
      "tree-sitter"
      "uchardet"
      "ueberzugpp"
      "unar"
      "uv"
      "vercel-cli"
      "viu"
      "watch"
      "websocat"
      "wget"
      "yarn"
      "yazi"
      "yq"
      "zellij"
      "zoxide"
      "zsh"
      "zsh-autocomplete"
      "zsh-history-substring-search"
      "zsh-syntax-highlighting"

      # other
      "chafa" "libsixel" "spdlog" "tbb"
      "cfitsio" "cgif" "libaec" "hdf5" "libmatio"
      "libspng" "uthash" "libdicom" "libxml2"
      "openslide" "vips"
    ];
    # Add casks (macOS applications)
    casks = [
      "launchcontrol"
      "qbserve"
      "pearcleaner"
      "hammerspoon"
      "betterzip"
      "arq"
      "shottr"
      "zed"
      "dropbox"
      "dropbox-dash"
      "proton-mail"
      "proton-mail-bridge"
      "protonvpn"
      "proton-pass"
      "proton-drive"
      "vivaldi"
      "airbuddy"
      "aldente"
      "bettertouchtool"
      "bartender"
      "cleanmymac"
      "clop"
      "dash"
      "hazeover"
      "popclip"
      "deepl"
      "devutils"
      "orion"
      "neohtop"
      "telegram-desktop"
      "telegram"
      "windsurf"
      "podman-desktop"
      "lm-studio"
      "oracle-jdk"
      "ollama"
      "ollamac"
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "balenaetcher"
      "fsmonitor"
      "folx"
      "istat-menus"
      "busycal"
      "busycontacts"
      "calibre"
      "dbeaver-community"
      "cursor"
      "figma"
      "karabiner-elements"
      "raycast"
      # "font-hack-nerd-font"
      # "font-jetbrains-mono-nerd-font"
      # "font-symbols-only-nerd-font"
      "fontforge"
      "git-credential-manager"
      "google-chrome"
      "iina"
      "iterm2"
      "itermai"
      "macpilot"
      "mediainfo"
      "monitorcontrol"
      "mos"
      "notion"
      "obsidian"
      "postman"
      "qlcolorcode"
      "qlmarkdown"
      "qlstephen"
      "quicklook-json"
      "quicklookase"
      "send-to-kindle"
      "sf-symbols"
      "sublime-text"
      "syntax-highlight"
      "visual-studio-code"
      "warp"
      "zoom"
    ];
  };
}
