{
  config,
  lib,
  pkgs,
  ...
}:

{
  system.defaults.dock = {
    persistent-apps = [
      # { app = "/Applications/ForkLift.app"; }
      # { app = "/Applications/Orion.app"; }
      # { app = "/Applications/Vivaldi.app"; }
      # { app = "/Applications/Brave Browser.app"; }
      { app = "/Applications/Safari.app"; }
      { app = "/Applications/Proton Mail.app"; }
      # { app = "/Applications/Google Chrome.app"; }
      # { app = "/Applications/Canary Mail.app"; }
      { app = "/Applications/Telegram Desktop.app"; }

      {
        spacer = {
          small = true;
        };
      }

      { app = "/Applications/Microsoft Outlook.app"; }
      { app = "/Applications/Microsoft Teams.app"; }

      {
        spacer = {
          small = true;
        };
      }

      { app = "/Applications/Windows App.app"; }
      # { app = "/Applications/Warp.app"; }
      # { app = "/Applications/Ghostty.app"; }
      # { app = "/Applications/WezTerm.app"; }
      # { app = "/Applications/Cursor.app"; }
      # { app = "/Applications/Antigravity.app"; }
      { app = "/Applications/Zed.app"; }
      { app = "/Applications/Visual Studio Code.app"; }
      { app = "/Applications/iTerm.app"; }
      { app = "/Applications/supacode.app/"; }
      # { app = "/Applications/Setapp/Maestri.app"; }

      {
        spacer = {
          small = true;
        };
      }

      { app = "/System/Applications/System Settings.app"; }
      # { app = "/Applications/ProcessSpy.app"; }
      { app = "/System/Applications/Utilities/Activity Monitor.app"; }

      {
        spacer = {
          small = true;
        };
      }

      # { app = "/Applications/Todoist.app"; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/DEVONthink.app"; }
      { app = "/Applications/Tana Outliner.app"; }
      { app = "/Applications/Obsidian.app"; }
      { app = "/Applications/Proton Pass.app"; }
      { app = "/Applications/NetNewsWire.app"; }
      { app = "/Applications/Clop.app"; }

      # Safari Web App for Home Assistant (http://192.168.20.32:8123).
      # Created via Safari "Add to Dock" — the bundle is NOT reproduced by nix,
      # so on a fresh machine re-create it before this entry resolves.
      { app = "/Users/yarnaid/Applications/Home Assistant.app"; }
      # { app = "/Applications/Drafts.app"; }
      # { app = "/System/Applications/iPhone Mirroring.app"; }
      # { app = "/Applications/Spotify.app"; }
      # { app = "/System/Applications/Music.app"; }
      # { app = "/Applications/Яндекс Музыка.app"; }

    ];
  };
}
