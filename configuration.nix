{ pkgs, lib, ... }:
{
  imports = [
    ./brew.nix
    ./kanata.nix
    ./mas.nix
    ./env.nix
    ./dock.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nixfmt
    # appcleaner
    cacert
    fish
  ];
  stylix.fonts.monospace.name = "MonoLisa Nerd Font";

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 10;
      options = "--delete-older-than 10d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
    optimise = {
      automatic = true;
      interval = {
        Hour = 12;
      };
    };
    settings = {
      ssl-cert-file = "/etc/ssl/cert.pem";
    };
  };

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 4.0;

  system.defaults.CustomSystemPreferences = {
    NSGlobalDomain = {
      TISRomanSwitchState = 1;
    };
    "com.apple.Safari" = {
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
    };
  };
  system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
  system.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
  system.defaults.NSGlobalDomain.AppleMetricUnits = 1;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
  system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  system.defaults.NSGlobalDomain._HIHideMenuBar = false;
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
  system.defaults.dock.autohide = true;
  system.defaults.dock.autohide-delay = 0.0;
  system.defaults.dock.autohide-time-modifier = 0.25;
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
  system.primaryUser = "yarnaid";
  # system.defaults.universalaccess.reduceMotion = true;

  # Add fish to /etc/shells
  environment.shells = with pkgs; [
    fish
    zsh
    bash
    nushell
  ];
  system.activationScripts.allowPerUserFish.text = ''
    perUserFish="/etc/profiles/per-user/yarnaid/bin/fish"
    if [ -x "$perUserFish" ]; then
      grep -qxF "$perUserFish" /etc/shells || echo "$perUserFish" >> /etc/shells
    fi
  '';

  # Disable Spotlight indexing on every volume + stop the metadata server.
  # `mdutil -a -i off` flips indexing flag persistently; `-E` erases the index;
  # `launchctl bootout` stops mds/mds_stores until next boot (system relaunches
  # them on activation, but with no work to do they idle). SIP prevents fully
  # unloading the LaunchDaemons, so we re-run on every activation.
  system.activationScripts.disableSpotlight.text = ''
    /usr/bin/mdutil -a -i off >/dev/null 2>&1 || true
    /usr/bin/mdutil -a -E      >/dev/null 2>&1 || true
    /bin/launchctl bootout system /System/Library/LaunchDaemons/com.apple.metadata.mds.plist >/dev/null 2>&1 || true
  '';

  # Set Git commit hash for darwin-version.
  system.configurationRevision = null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User configuration
  users.users.yarnaid = {
    name = "yarnaid";
    home = "/Users/yarnaid";
    shell = pkgs.fish;
  };
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  environment.etc."sudoers.d/powermetrics-yarnaid".text =
    "yarnaid ALL=(root) NOPASSWD: /usr/bin/powermetrics\n";

  # darwin-rebuild now requires root for system activation. Allow yarnaid
  # to invoke it without a password prompt. The store-path symlink changes
  # on every rebuild, so we list both stable wrapper paths and a wildcard
  # for the nix-store target.
  environment.etc."sudoers.d/darwin-rebuild-yarnaid".text = ''
    yarnaid ALL=(root) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
    yarnaid ALL=(root) NOPASSWD: /nix/var/nix/profiles/system/sw/bin/darwin-rebuild
    yarnaid ALL=(root) NOPASSWD: /nix/store/*-darwin-rebuild*/bin/darwin-rebuild
  '';

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # Add backup extension for existing files
    users.yarnaid = import ./home.nix;
  };
}
