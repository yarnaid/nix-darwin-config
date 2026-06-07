{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap"; # Uninstall all programs not declared
      # Homebrew 5.x requires --force/--force-cleanup/$HOMEBREW_ASK alongside
      # `brew bundle --cleanup`, else activation aborts with "Invalid usage".
      # --force-cleanup restores prior non-interactive zap (cleanup only, no
      # --overwrite). nix-darwin appends extraFlags after `--cleanup --zap`.
      extraFlags = [ "--force-cleanup" ];
    };
    global = {
      brewfile = true;
      autoUpdate = true;
    };
    # Add taps (repositories)
    taps = [
      "houmain/tap"
      "acarl005/formulas"
      "domt4/autoupdate"
      "felixkratz/formulae"
      "lzt1008/powerflow"
      "jesseduffield/lazygit"
      "jstkdng/programs"
      "nikitabobko/tap"
      "arnested/ssh2iterm2"
    ];
    # Add brews (packages)
    brews = [
      {
        name = "sketchybar";
        start_service = false;
      }
      "ccusage" # CLI tool for analyzing Claude Code usage from local JSONL files
      "mole" # Deep clean and optimize your Mac
      "carapace" # Multi-shell multi-command argument completer
      "gawk" # GNU awk utility
      "gnu-tar" # GNU version of the tar archiving utility
      "findutils" # Collection of GNU find, xargs, and locate
      "gnu-getopt" # Command-line option parsing utility — dep of: git-now
      "gnu-sed" # GNU implementation of the famous stream editor — dep of: quilt
      "coreutils" # GNU File, Shell, and Text utilities — dep of: quilt
      "diffutils" # File comparison utilities — dep of: quilt
      "gpatch" # Apply a diff file to an original — dep of: quilt
      "grep" # GNU grep, egrep and fgrep
      "swig" # Generate scripting interfaces to C/C++ code
      "subversion" # Version control system designed to be a better CVS
      "rustup" # Rust toolchain installer
      "codecrafters-io/tap/codecrafters" # CodeCrafters CLI
      "exercism" # Command-line tool to interact with exercism.io
      "mise" # Polyglot runtime manager (asdf rust clone)
      "swiftlint" # Tool to enforce Swift style and conventions
      "bat" # Clone of cat(1) with syntax highlighting and Git integration
      "btop" # Resource monitor. C++ version and continuation of bashtop and bpytop
      "broot" # New way to see and navigate directory trees
      "eza" # Modern, maintained replacement for ls
      "ranger" # File browser
      "yazi" # Blazing fast terminal file manager written in Rust, based on async I/O
      "zellij" # Pluggable terminal workspace, with terminal multiplexer as the base feature
      "nvm" # Manage multiple Node.js versions
      "pnpm" # Fast, disk space efficient package manager
      "podman" # Tool for managing OCI containers and pods — dep of: podman-compose
      "podman-compose" # Alternative to docker-compose using podman
      "bgrep" # Like grep but for binary strings
      "chezmoi" # Manage your dotfiles across multiple diverse machines, securely
      "hidapi" # Library for communicating with USB and Bluetooth HID devices
      "make" # Utility for directing compilation
      "cmake" # Cross-platform make
      "curl" # Get a file from an HTTP, HTTPS or FTP server
      "duti" # CLI to set per-UTI default apps (used by defaultFolderHandler activation script)
      "e2fsprogs" # Utilities for the ext2, ext3, and ext4 file systems
      "entr" # Run arbitrary commands when files change
      "exiftool" # Perl lib for reading and writing EXIF metadata
      "fastfetch" # Like neofetch, but much faster because written mostly in C
      "fd" # Simple, fast and user-friendly alternative to find
      "ffmpeg" # Play, record, convert, and stream select audio and video codecs — dep of: ffmpegthumbnailer, mpv
      "ffmpegthumbnailer" # Create thumbnails for your video files
      "fftw" # C routines to compute the Discrete Fourier Transform — dep of: vips
      "flac" # Free lossless audio codec — dep of: ffmpegthumbnailer, libsndfile, mpv, rubberband, sox
      "fmt" # Open-source formatting library for C++ — dep of: ada-url, node, prettier, pyright, spdlog
      "fontconfig" # XML-based font configuration API for X Windows — dep of: cairo, chafa, djvu2pdf, ffmpegthumbnailer, fontforge +20 more
      "fontforge" # Command-line outline and bitmap font editor/converter
      "forgit" # Interactive git commands in the terminal
      "freetype" # Software library to render fonts — dep of: cairo, chafa, djvu2pdf, ffmpegthumbnailer, fontconfig +23 more
      "fzy" # Fast, simple fuzzy text selector with an advanced scoring algorithm
      "gcc" # GNU compiler collection — dep of: hdf5, libmatio, vips
      "gh" # GitHub command-line tool
      "git" # Distributed revision control system
      "git-cal" # GitHub-like contributions calendar but on the command-line
      "git-delta" # Syntax-highlighting pager for git and diff output
      "git-extras" # Small git utilities
      "git-hooks-go" # Git hooks manager
      "git-imerge" # Incremental merge for git
      "git-now" # Light, temporary commits for git
      "git-recent" # Browse your latest git branches, formatted real fancy
      "git-when-merged" # Find where a commit was merged in git
      "glow" # Render markdown on the CLI
      "gnutls" # GNU Transport Layer Security (TLS) Library — dep of: ffmpegthumbnailer, gnupg, gpgme, gpgmepp, libmicrohttpd +4 more
      "go" # Open source programming language to build simple/reliable/efficient software
      "gperf" # Perfect hash function generator
      "graphicsmagick" # Image processing tools collection
      "graphviz" # Graph visualization software from AT&T and Bell Labs — dep of: plantuml
      "hadolint" # Smarter Dockerfile linter to validate best practices
      "highlight" # Convert source code to formatted text with syntax highlighting
      "howdoi" # Instant coding answers via the command-line
      "htop" # Improved top (interactive process viewer)
      "hyperfine" # Command-line benchmarking tool
      "imagemagick" # Tools and libraries to manipulate images in select formats — dep of: vips
      "iperf3" # Update of iperf: measures TCP, UDP, and SCTP bandwidth
      "jq" # Lightweight and flexible command-line JSON processor
      "kanata" # Cross-platform software keyboard remapper for Linux, macOS and Windows
      "lame" # High quality MPEG Audio Layer III (MP3) encoder — dep of: ffmpeg, ffmpegthumbnailer, libsndfile, mpv, rubberband +1 more
      "lazygit" # Simple terminal UI for git commands
      "lf" # Terminal file manager
      "libexif" # EXIF parsing library — dep of: vips
      "llvm" # Next-gen compiler infrastructure — dep of: rust
      "lpeg" # Parsing Expression Grammars For Lua — dep of: neovim
      "ls-go" # A more colorful, user-friendly implementation of `ls` written in Go
      "lsd" # Clone of ls with colorful output, file type icons, and more
      "lua" # Powerful, lightweight programming language — dep of: fastfetch, highlight, luarocks
      "lua-language-server" # Language Server for the Lua language
      "luajit" # Just-In-Time Compiler (JIT) for the Lua programming language — dep of: mpv, neovim
      "luarocks" # Package manager for the Lua programming language
      "lynx" # Text-based web browser
      "lzo" # Real-time data compression library — dep of: cairo, chafa, djvu2pdf, ffmpegthumbnailer, fontforge +18 more
      "mas" # Mac App Store command-line interface
      "marksman" # Language Server Protocol for Markdown
      "miller" # Like sed, awk, cut, join & sort for name-indexed data such as CSV
      "mozjpeg" # Improved JPEG encoder — dep of: vips
      "mpg123" # MP3 player for Linux and UNIX — dep of: ffmpegthumbnailer, libsndfile, mpv, rubberband, sox
      "mpv" # Media player based on MPlayer and mplayer2
      "mujs" # Embeddable Javascript interpreter — dep of: mpv
      "mupdf" # Lightweight PDF and XPS viewer — dep of: pymupdf
      "ncdu" # NCurses Disk Usage
      "neovim" # Ambitious Vim-fork focused on extensibility and agility
      "netcat" # Utility for managing network connections
      "netpbm" # Image manipulation — dep of: graphviz, gts, plantuml
      "ninja" # Small build system for use with gyp or CMake
      "nlohmann-json" # JSON for modern C++
      "ouch" # Painless compression and decompression for your terminal
      "p7zip" # 7-Zip (high compression file archiver) implementation
      "pandoc" # Swiss-army knife of markup format conversion
      "pango" # Framework for layout and rendering of i18n text — dep of: chafa, djvu2pdf, ffmpegthumbnailer, fontforge, ghostscript +7 more
      "pdftoipe" # Reads arbitrary PDF files and generates an XML file readable by Ipe
      "pillow" # Friendly PIL fork (Python Imaging Library)
      "pinentry" # Passphrase entry dialog utilizing the Assuan protocol — dep of: gnupg, gpgme, gpgmepp, pdftoipe, poppler +1 more
      "pinentry-mac" # Pinentry for GPG on Mac
      "pixman" # Low-level library for pixel manipulation — dep of: cairo, chafa, djvu2pdf, ffmpegthumbnailer, fontforge +18 more
      "pkgconf" # Package compiler and linker metadata toolkit — dep of: hdf5, libmatio, rust, vips
      "plantuml" # Draw UML diagrams
      "poppler" # PDF rendering library (based on the xpdf-3.0 code base) — dep of: pdftoipe, vips
      "prettier" # Code formatter for JavaScript, CSS, JSON, GraphQL, Markdown, YAML
      "procs" # Modern replacement for ps written in Rust
      "pymupdf" # Python bindings for the PDF toolkit and renderer MuPDF
      "pyright" # Static type checker for Python
      "python-lsp-server" # Python Language Server for the Language Server Protocol
      "python-setuptools" # Easily download, build, install, upgrade, and uninstall Python packages
      "ripgrep" # Search tool like grep and The Silver Searcher — dep of: anomalyco/tap/opencode, codex, ripgrep-all
      "ripgrep-all" # Wrapper around ripgrep that adds multiple rich file types
      "rsync" # Utility that provides fast incremental file transfer
      "rust" # Safe, concurrent, practical language
      "sevenzip" # 7-Zip is a file archiver with a high compression ratio
      "shared-mime-info" # Database of common MIME types
      "smartmontools" # SMART hard drive monitoring
      "snappy" # Compression/decompression library aiming for high speed — dep of: ffmpegthumbnailer
      "socat" # SOcket CAT: netcat on steroids
      "starship" # Cross-shell prompt for astronauts
      "stylua" # Opinionated Lua code formatter
      "terminal-notifier" # Send macOS User Notifications from the command-line
      "tlrc" # Official tldr client written in Rust
      "tmux" # Terminal multiplexer
      "tokei" # Program that allows you to count code, quickly
      "tree" # Display directories as trees (with optional color/HTML output)
      "uchardet" # Encoding detector library — dep of: mpv
      "unar" # Command-line unarchiving tools supporting multiple formats
      "uv" # Extremely fast Python package installer and resolver, written in Rust
      "viu" # Simple terminal image viewer written in Rust
      "watch" # Executes a program periodically, showing output fullscreen
      "websocat" # Command-line client for WebSockets
      "wget" # Internet file retriever
      "yarn" # JavaScript package manager
      "yq" # Process YAML, JSON, XML, CSV and properties documents from the CLI
      "zsh-autocomplete" # Real-time type-ahead completion for Zsh

      # other
      "chafa" # Versatile and fast Unicode/ASCII/ANSI graphics renderer
      "libsixel" # SIXEL encoder/decoder implementation
      "spdlog" # Super fast C++ logging library
      "tbb" # Rich and complete approach to parallelism in C++
      "cfitsio" # C access to FITS data files with optional Fortran wrappers — dep of: vips
      "cgif" # GIF encoder written in C — dep of: vips
      "libaec" # Adaptive Entropy Coding implementing Golomb-Rice algorithm — dep of: hdf5, libmatio, vips
      "hdf5" # File format designed to store large amounts of data — dep of: libmatio, vips
      "libmatio" # C library for reading and writing MATLAB MAT files — dep of: vips
      "libspng" # C library for reading and writing PNG format files
      "uthash" # C macros for hash tables and more — dep of: libdicom, openslide, vips
      "libdicom" # DICOM WSI read library — dep of: openslide, vips
      "libxml2" # GNOME XML library — dep of: openslide, vips
      "openslide" # C library to read whole-slide images (a.k.a. virtual slides) — dep of: vips
      "vips" # Image processing library
      "helix" # Post-modern modal text editor
      "ruby" # Powerful, clean, object-oriented scripting language — dep of: cocoapods
      "cocoapods" # Dependency manager for Cocoa projects

      # ─── added by add_tools.sh ───
      "xh" # HTTPie на Rust, ~10× быстрее, тот же синтаксис
      "doggo" # современный dig: цветной, JSON, DoH/DoT/DoQ
      "gron" # JSON → greppable строки: `cat x.json | gron | grep …`
      "dasel" # селектор JSON/YAML/TOML/XML/CSV единым синтаксисом
      "just" # запускалка project-команд, лучше Make
      "navi" # interactive cheatsheets (Ctrl-G), shell-friendly
      "lnav" # лог-навигатор с SQL-фильтром и парсингами форматов
      "dust" # `du` с барами и UTF-8 деревом
      "bottom" # `btm` — современный TUI-монитор, UX лучше btop на macOS
      "bandwhich" # network usage per-process (нужен sudo)
      "pueue" # очередь долгих команд (docker build, pip, ffmpeg)
      "glab" # GitLab CLI (для EPAM GitLab)
      "act" # запуск GitHub Actions локально через Docker/podman
      "anomalyco/tap/opencode" # AI coding agent, built for the terminal
      "arnested/ssh2iterm2/ssh2iterm2" # SSH config → iTerm2 dynamic profiles

    ];
    # Add casks (macOS applications)
    casks = [
      "aldente" # (AlDente) Menu bar tool to limit maximum charging percentage
      "app-tamer" # (AppTamer) CPU management application
      "unifi-identity-endpoint" # (UniFi Identity Endpoint) License free Wi-Fi, VPN, and Access Application for Organizations
      "ssh-config-editor" # (SSH Config Editor) Tool for managing the OpenSSH ssh client configuration file
      "macfuse" # (macFUSE) File system integration
      "typora" # (Typora) Configurable document editor that supports Markdown
      "qlstephen" # (QLStephen) Quick Look plugin for plaintext files without an extension
      "qlmobi" # (QLMobi) Quick Look plugin for Kindle ebook formats
      "tabby" # (Tabby, Terminus) Terminal emulator, SSH and serial client
      "devknife" # (DevKnife) Collection of handy developer tools
      "little-snitch" # (Little Snitch) Host-based application firewall
      "downie" # (Downie) Downloads videos from different websites
      "tiny-shield" # (Tiny Shield) Control and monitor network connections
      "macwhisper" # (MacWhisper) Speech recognition tool

      "libreoffice" # (LibreOffice) Free cross-platform office suite, fresh version
      "keycastr" # (KeyCastr) Open-source keystroke visualiser
      "spotify" # (Spotify) Music streaming service
      "supasidebar" # (SupaSidebar) Arc-like sidebar to save links, files and folders from any browser
      "claude" # (Claude) Anthropic's official Claude AI desktop app
      "antinote" # (Antinote) Temporary notes with calculations and extensible features
      "processspy" # (ProcessSpy) Process monitor
      "lasso-app" # (Lasso) Move and resize windows with mouse
      "soundsource" # (SoundSource) Sound and audio controller
      "rectangle-pro" # (Rectangle Pro) Window snapping tool
      "applite" # (Applite) User-friendly GUI app for Homebrew
      "adguard" # (AdGuard) Stand alone ad blocker
      "qutebrowser" # (qutebrowser) Keyboard-driven, vim-like browser based on PyQt5
      "codex" # (Codex) OpenAI's coding agent that runs in your terminal
      "basictex" # (BasicTeX) Compact TeX distribution as alternative to the full TeX Live / MacTeX
      "orbstack" # (OrbStack) Replacement for Docker Desktop
      "zen" # (Zen Browser) Gecko based web browser
      "mouseless" # (Mouseless) Mouse control with the keyboard

      "istat-menus" # (iStats Menus) System monitoring app
      "reader" # (Readwise Reader) Save articles to read, highlight key content, and organise notes for review
      "bleunlock" # (BLEUnlock) Lock/unlock Apple computers using the proximity of a bluetooth low energy device
      "istherenet" # (IsThereNet) Your internet connection status at a glance
      "powerflow" # (Powerflow) macOS App for monitoring power usage and charging status
      "betterdisplay" # (BetterDisplay) Display management tool
      "coconutbattery" # (coconutBattery) Tool to show live information about the batteries in various devices
      "homerow" # (Homerow) Keyboard shortcuts for every button on your screen
      "launchcontrol" # (LaunchControl) Create, manage and debug system and user services
      "qbserve" # (Qbserve) Automatic time tracker
      "pearcleaner" # (Pearcleaner) Utility to uninstall apps and remove leftover files from old/uninstalled apps
      "betterzip" # (BetterZip) Utility to create and modify archives
      "arq" # (Arq) Multi-cloud backup application
      "zed" # (Zed) Multiplayer code editor
      "anki" # (Anki) Memory training application
      "leader-key" # (Leader Key) Application launcher
      "script-debugger" # (Script Debugger) Integrated development environment focused entirely on AppleScript
      "dropbox" # (Dropbox) Client for the Dropbox cloud storage service
      "forklift" # (ForkLift) Finder replacement and FTP, SFTP, WebDAV and Amazon s3 client
      "anytype" # (Anytype) Local-first and end-to-end encrypted notes app
      "reverso" # (Reverso) Text translation application
      "cleanshot" # (CleanShot) Screen capturing tool
      "ghostty" # (Ghostty) Terminal emulator that uses platform-native UI and GPU acceleration
      "kindavim" # (kindaVim) Use Vim in input fields and non input fields
      "keyboard-maestro" # (Keyboard Maestro) Automation software
      "proton-mail" # (Proton Mail) Client for Proton Mail and Proton Calendar
      "proton-mail-bridge" # (Proton Mail Bridge) Bridges Proton Mail to email clients supporting IMAP and SMTP protocols
      "protonvpn" # (ProtonVPN) VPN client focusing on security
      "proton-pass" # (Proton Pass) Desktop client for Proton Pass
      "vivaldi" # (Vivaldi) Web browser with built-in email client focusing on customization and control
      "airbuddy" # (AirBuddy) AirPods companion app
      "bettertouchtool" # (BetterTouchTool) Tool to customise input devices and automate computer systems
      "cleanmymac" # (CleanMyMac) Tool to remove unnecessary files and folders from disk
      "clop" # (Clop) Image, video and clipboard optimiser
      "dash" # (Dash) API documentation browser and code snippet manager
      "popclip" # (PopClip) Used to access context-specific actions when text is selected
      "devutils" # (DevUtils) All-in-one toolbox for developers
      "orion" # (Orion Browser) WebKit based web browser
      "telegram-desktop" # (Telegram Desktop) Desktop client for Telegram messenger
      "podman-desktop" # (Podman Desktop) Browse, manage, inspect containers and images
      "lm-studio" # (LM Studio) Discover, download, and run local LLMs
      "ollama-app" # (Ollama) Get up and running with large language models locally
      "balenaetcher" # (Etcher) Tool to flash OS images to SD cards & USB drives
      "fsmonitor" # (FSMonitor) Visualize filesystem changes in realtime
      "folx" # (Folx) Download manager with a torrent client
      "dbeaver-community" # (DBeaver Community Edition) Universal database tool and SQL client
      "cursor" # (Cursor) Write, edit, and chat about your code with AI
      "figma" # (Figma) Collaborative team software
      "karabiner-elements" # (Karabiner Elements) Keyboard customiser
      "git-credential-manager" # (Git Credential Manager) Cross-platform Git credential storage for multiple hosting providers
      "google-chrome" # (Google Chrome) Web browser
      "iina" # (IINA) Free and open-source media player
      "iterm2" # (iTerm2) Terminal emulator as alternative to Apple's Terminal app
      "itermai" # (iTerm2 AI Plugin) Enable generative AI features in iTerm2
      "macpilot" # (MacPilot) Graphical user interface for the command terminal
      "mediainfo" # (MediaInfo) Display technical and tag data for video and audio files
      "mos" # (Mos) Smooths scrolling and set mouse scroll directions independently
      "postman" # (Postman) Collaboration platform for API development
      "send-to-kindle" # (Send to Kindle) Tool for sending personal documents to Kindles from Macs
      "sf-symbols" # (SF Symbols) Tool that provides consistent, highly configurable symbols for apps
      "sublime-text" # (Sublime Text) Text editor for code, markup and prose
      "syntax-highlight" # (Syntax Highlight) Quicklook extension for source files
      "visual-studio-code" # (Microsoft Visual Studio Code, VS Code) Open-source code editor
      "warp" # (Warp) Rust-based terminal
      "wezterm" # (WezTerm) GPU-accelerated cross-platform terminal emulator and multiplexer
      "zoom" # (Zoom) Video communication and virtual meeting platform
    ];
  };
}
