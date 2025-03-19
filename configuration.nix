{ pkgs, ... }: {
  imports =
    [ ./brew.nix ./kanata.nix ./mas.nix ./env.nix ./aerospace.nix ./dock.nix ];
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
    bat
    git
    neovim
    nixfmt-classic
    eza
    ranger
    yazi
    fish
    wget
    curl
    appcleaner
    arc-browser
    iina
    iterm2
    karabiner-elements
    languagetool
    obsidian
    raycast
    tailscale
    telegram-desktop
  ];

  # System-wide shell aliases
  environment.shellAliases = {
    # Vim related
    vim = "nvim";
    v = "vim";

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

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 30;
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
    optimise = {
      automatic = true;
      interval = { Hour = 12; };
    };
    settings = { };
  };

  # Enable fish shell system-wide
  programs.fish.enable = true;
  programs.direnv.enable = true;

  services.openssh.enable = true;
  services.sketchybar.enable = true;
  services.tailscale.enable = true;

  system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 4.0;

  system.defaults.CustomSystemPreferences = {
    NSGlobalDomain = { TISRomanSwitchState = 1; };
    "com.apple.Safari" = {
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
        true;
    };
  };
  system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically =
    true;
  system.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
  system.defaults.NSGlobalDomain.AppleMetricUnits = 1;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = false;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
  system.defaults.WindowManager.AppWindowGroupingBehavior = false;
  system.defaults.controlcenter.AirDrop = false;
  system.defaults.controlcenter.Bluetooth = false;
  system.defaults.controlcenter.Sound = false;
  system.defaults.dock.expose-animation-duration = 1.0e-2;
  system.defaults.dock.expose-group-apps = true;
  system.defaults.dock.magnification = true;
  system.defaults.dock.largesize = 38;
  system.defaults.dock.tilesize = 32;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.orientation = "bottom";
  system.defaults.dock.wvous-br-corner = 1;
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.AppleShowAllFiles = true;
  system.defaults.finder.FXDefaultSearchScope = "SCcf";
  system.defaults.finder.FXPreferredViewStyle = "Nlsv";
  system.defaults.finder.NewWindowTarget = "Home";
  system.defaults.finder.ShowExternalHardDrivesOnDesktop = false;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.finder.ShowRemovableMediaOnDesktop = false;
  system.defaults.finder.ShowStatusBar = true;
  system.defaults.finder._FXShowPosixPathInTitle = true;
  system.defaults.hitoolbox.AppleFnUsageType = "Change Input Source";
  system.defaults.menuExtraClock.Show24Hour = true;
  system.defaults.menuExtraClock.ShowDate = 2;
  system.defaults.menuExtraClock.ShowSeconds = true;
  system.defaults.trackpad.Clicking = true;
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
  system.defaults.trackpad.TrackpadThreeFingerTapGesture = 0;
  # system.defaults.universalaccess.reduceMotion = true;

  # Add fish to /etc/shells
  environment.shells = [ pkgs.fish ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  system.defaults.dock.autohide = false;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User configuration
  users.users.yarnaid = {
    name = "yarnaid";
    home = "/Users/yarnaid";
    shell = pkgs.fish;
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # Add backup extension for existing files
    users.yarnaid = import ./home.nix;
  };
}
