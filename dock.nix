{ config, lib, pkgs, ... }:

{
  system.defaults.dock = {
    persistent-apps = [
      { app = "/Applications/Arc.app"; }
      { app = "/Applications/Proton Mail.app"; }
      { app = "/Applications/Telegram.app"; }
      {
        spacer = { small = true; };
      }
      {
        app = "/Applications/Microsoft Outlook.app";
      }
      { app = "/Applications/Microsoft Teams.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Windows App.app"; }
      # { app = "/Applications/Warp.app"; }
      { app = "/Applications/iTerm.app"; }
      { app = "/Applications/Cursor.app"; }
      # { app = "/Applications/Zed.app"; }
      { app = "/Applications/Visual Studio Code.app"; }

      { spacer = { small = true; }; }

      { app = "/System/Applications/System Settings.app"; }
      { app = "/System/Applications/Utilities/Activity Monitor.app"; }

      { spacer = { small = true; }; }

      { app = "/Applications/Todoist.app"; }
      { app = "/Applications/Things3.app"; }
      {
        app = "/Applications/Tana.app";
      }
      # { app = "/Applications/Drafts.app"; }
      { app = "/System/Applications/iPhone Mirroring.app"; }
      { app = "/Applications/Spotify.app"; }

    ];
  };
}
