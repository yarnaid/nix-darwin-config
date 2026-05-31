{ ... }:
{
  homebrew.masApps = {
    # Productivity
    "Things" = 904280696;
    "USB Status" = 6751750190;
    "Microsoft Excel" = 462058435;
    "Microsoft Word" = 462054704;
    "Microsoft PowerPoint" = 462062816;
    "Microsoft Outlook" = 985367838;
    "Pages" = 409201541;
    "Numbers" = 409203825;
    "Keynote" = 409183694;
    "Soulver 3" = 1508732804;
    "LiquidText" = 922765270;
    # Not available in current App Store region ("No apps found in the App
    # Store for ADAM ID 6743316600") — aborts `brew bundle`. Same class as
    # the Swiftgram entry below.
    # "Subscription Day" = 6743316600;

    # Email & Communication
    "Canary Mail" = 1236045954;
    "rcmd" = 1596283165;
    # iOS app (no native Mac build) — runs on Apple Silicon via App Store.
    # "Swiftgram: Telegram mod client" = 6471879502;

    # Utilities
    # "Disk Space Analyzer" = 446243721;
    "Blackmagic Disk Speed Test" = 425264550;
    "Apple Configurator" = 1037126344;
    "Amphetamine" = 937984704;
    "OneDrive" = 823766827;
    "Key Codes" = 414568915;
    "WiFi Explorer" = 494803304;
    "WiFi Signal" = 525912054;
    "Windows App" = 1295203466;
    "Speedtest" = 1153157709;
    "Itsyhome" = 6758070650;
    "Barbee - Hide Menu Bar Items" = 1548711022;

    # Development & Power User Tools
    "JSON Peep" = 1458969831;
    "Peek" = 1554235898;
    "Super Agent" = 1568262835;
    "Xcode" = 497799835;
    # LanguageTool (id 1534275760): not managed here — App Store reports
    # its version as "v8.21.1" while installed is "8.21.1", so mas compares
    # strings as different and `brew bundle` keeps trying to reinstall on
    # every activation. App Store auto-updates handle this anyway.
    # See https://github.com/mas-cli/mas/issues/164
    "Raycast Companion" = 6738274497;

    # Browser Extensions & Web Tools
    "Vimlike" = 1584519802;
    "StopTheMadness Pro" = 6471380298;
    "Kagi for Safari" = 1622835804;
    "Hover for Safari" = 1540705431;
    "Karma" = 1481191441;
    "Fakespot" = 1592541616;
    "Hush" = 1544743900;
    "Keyword Search" = 1558453954;
    "Proton Pass for Safari" = 6502835663;
    "SponsorBlock" = 1573461917;
    "SingleFile" = 6444322545;
    "ImproveTube" = 1672777754;

    # Network & System Tools
    "Tailscale" = 1475387142;
    "Screens 5" = 1663047912;
    "UnTrap" = 1637438059;

    # Media & Graphics
    "Pixelmator Pro" = 1289583905;
    "YamaCast" = 1415107621;
    "Unsplash Wallpapers" = 1284863847;
    "Video Speed Controller" = 1588368612;

    # Weather & Lifestyle
    "flowy" = 6748351905;
    "Save to Reader" = 1640236961;
    "iFinance 5" = 1500241909;
    "MacFamilyTree 11" = 6480510488;
  };
}
