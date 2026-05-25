{ pkgs, lib, ... }:
{
  imports = [
    ./brew.nix
    ./kanata.nix
    ./mas.nix
    ./env.nix
    ./dock.nix
    ./logging.nix
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

  # Kill Siri Suggestions + Look Up suggestions (both feed Spotlight results).
  system.defaults.CustomUserPreferences = {
    "com.apple.suggestions".SuggestionsAppLibraryEnabled = false;
    "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
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
  system.defaults.WindowManager.GloballyEnabled = false;
  system.defaults.WindowManager.AutoHide = false;
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

  # Pin Finder as the explicit handler for folder UTIs so a cask install (ForkLift,
  # qutebrowser, etc.) can't silently hijack the binding. macOS resolves folder
  # opens via LaunchServices; an empty LSHandlers entry resolves to Finder by
  # default, but is not guaranteed once another app registers itself.
  #
  # NOTE: nix-darwin's master `activate` script ONLY composes a fixed set of
  # phase names (`preActivation`, `extraActivation`, `postActivation`, plus
  # built-in phases like `defaults`, `homebrew`, etc.). Custom-named scripts
  # are silently dropped. Activation runs as root — per-user actions need sudo.
  system.activationScripts.postActivation.text = ''
    # --- defaultFolderHandler: pin Finder for public.folder ---
    # Only public.folder is set: it's the concrete UTI for regular folders.
    # public.directory is an abstract supertype — LaunchServices returns
    # paramErr (-50) on attempts to bind it, and concrete folder opens always
    # resolve via the more-specific public.folder anyway.
    duti=/opt/homebrew/bin/duti
    user=yarnaid
    finder=com.apple.finder
    uti=public.folder
    if [ ! -x "$duti" ]; then
      echo "[defaultFolderHandler] $duti not installed yet; will run on next switch"
    else
      current="$(sudo -u "$user" "$duti" -d "$uti" 2>/dev/null || true)"
      if [ "$current" = "$finder" ]; then
        echo "[defaultFolderHandler] $uti already → $finder"
      else
        echo "[defaultFolderHandler] setting $uti → $finder (was: $current)"
        sudo -u "$user" "$duti" -s "$finder" "$uti" all
        sudo -u "$user" killall cfprefsd 2>/dev/null || true
      fi
    fi
  '';

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

  # Kill Spotlight's UI surfaces but KEEP indexing enabled.
  #
  # Why indexing must stay on: `mas` 7.x detects installed App Store apps via
  # `mdfind kMDItemAppStoreReceipt`. With indexing off, `mas list` returns
  # empty -> `brew bundle` thinks no MAS apps are installed -> reinstalls all
  # of `homebrew.masApps` on every `darwin-rebuild switch`. Trade-off chosen:
  # silent UI + working declarative MAS > fully dead Spotlight.
  #
  # What stays alive: mds/mds_stores daemons, the index itself, `mdfind`.
  # What we kill: menu-bar magnifier, Cmd-Space search panel, Cmd-Alt-Space
  # Finder search, and (declaratively, via system.defaults below) Siri /
  # Look Up suggestions. SIP prevents removing the per-user Spotlight
  # LaunchAgent permanently, so we `launchctl disable` it on every activation.
  system.activationScripts.disableSpotlight.text = ''
    uid=$(/usr/bin/id -u yarnaid)
    plist=/Users/yarnaid/Library/Preferences/com.apple.symbolichotkeys.plist

    # 1. Ensure indexing is on (recovers from a previously-disabled state).
    /usr/bin/mdutil -a -i on >/dev/null 2>&1 || true

    # 2. Disable + kill the per-user Spotlight UI agent (menu-bar magnifier
    #    icon and the Cmd-Space search panel). `disable` is persisted in
    #    ~/Library/LaunchAgents/...disabled.plist, so it survives reboots.
    /bin/launchctl asuser "$uid" /bin/launchctl disable "gui/$uid/com.apple.Spotlight" >/dev/null 2>&1 || true
    /bin/launchctl asuser "$uid" /bin/launchctl bootout  "gui/$uid/com.apple.Spotlight" >/dev/null 2>&1 || true

    # 3. Unbind Cmd-Space (hotkey id 64) and Cmd-Alt-Space (id 65) so even a
    #    relaunched Spotlight has no way to surface. PlistBuddy merges into
    #    the existing dict instead of clobbering other hotkeys; killall
    #    cfprefsd forces the prefs daemon to drop its cache.
    if [ -f "$plist" ]; then
      /usr/bin/sudo -u yarnaid /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" "$plist" >/dev/null 2>&1 || true
      /usr/bin/sudo -u yarnaid /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" "$plist" >/dev/null 2>&1 || true
      /usr/bin/sudo -u yarnaid /usr/bin/killall cfprefsd >/dev/null 2>&1 || true
    fi

    # 4. Kick off a one-shot reindex of /Applications so `mas list` can find
    #    installed App Store apps right after switch (instead of next idle).
    /usr/bin/mdimport /Applications >/dev/null 2>&1 || true
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
