{...}: {
  # Add directories to the system PATH
  environment.systemPath = [
    "/Users/yarnaid/.local/bin"
    "/Users/yarnaid/.yarn/bin"
    "/Users/yarnaid/.goenv/path/bin"
    "/Users/yarnaid/.goenv/go/bin"
    "/usr/local/sbin"
    "/usr/local/opt/sqlite/bin"
    "/usr/local/opt/gnu-sed/libexec/gnubin"
    "/Users/yarnaid/.cargo/bin"
    "/usr/local/bin"
    "/Applications/Postgres.app/Contents/Versions/15/bin"
  ];

  environment.variables = {
    # Python related
    WORKON_HOME = "/Users/yarnaid/.virtualenvs";

    # Development
    BUILDKIT_PROGRESS = "plain";

    # Go
    GOPATH = "/Users/yarnaid/.goenv/path";

    # Locale and display
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    CLICOLOR = "1";

    # Man pages
    MANPATH = "/usr/local/man:/usr/share/man";

    # Compilation flags
    LDFLAGS = "-L/usr/local/opt/openssl/lib";
    CPPFLAGS = "-I/usr/local/opt/openssl/include";

    # Homebrew
    HOMEBREW_AUTO_UPDATE_SECS = "86400";
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_UPGRADE_GREEDY = "1";
    HOMEBREW_BAT = "1";

    # Editor
    EDITOR = "nvim";
    VISUAL = "nvim";

    # FZF
    FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git --exclude node_modules";
    FZF_CTRL_T_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git --exclude node_modules";
    FZF_ALT_C_COMMAND = "fd --type=d --hidden --strip-cwd-prefix --exclude .git --exclude node_modules";
    FZF_ALT_C_OPTS = "--preview 'eza --tree --color=always {} | head -200'";

    # Pager
    PAGER = "bat";

    # Virtualenv
    VIRTUALENVWRAPPER_SCRIPT = "/opt/homebrew/bin/virtualenvwrapper.sh";
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
    ZSH_TMUX_TERM = "screen-256color";
    _VIRTUALENVWRAPPER_API = "mkvirtualenv rmvirtualenv lsvirtualenv showvirtualenv workon add2virtualenv cdsitepackages cdvirtualenv lssitepackages toggleglobalsitepackages cpvirtualenv setvirtualenvproject mkproject cdproject mktmpenv wipeenv allvirtualenv";
  };
} 