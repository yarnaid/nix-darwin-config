{ config, lib, pkgs, ... }:

{
  system.defaults.dock = {
    persistent-apps = [
      # { app = "/Applications/Safari.app"; }
      { app = "/Applications/Orion.app"; }
      { app = "/Applications/Dia.app"; }
      { app = "/Applications/Google Chrome.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Microsoft Outlook.app"; }
      { app = "/Applications/Setapp/Spark Mail.app"; }
      { app = "/Applications/Telegram.app"; }
      { app = "/Applications/Microsoft Teams.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Windows App.app"; }
      { app = "/Applications/Warp.app"; }
      { app = "/Applications/iTerm.app"; }
      { app = "/Applications/Cursor.app"; }
      { app = "/Applications/Windsurf.app"; }
      { app = "/Applications/Visual Studio Code.app"; }
      { spacer = { small = true; }; }
      { app = "/System/Applications/System Settings.app"; }
      { app = "/System/Applications/Utilities/Activity Monitor.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/Tana.app"; }
      { app = "/System/Applications/iPhone Mirroring.app"; }
      { app = "/Applications/Parcel.app"; }
      { app = "/System/Applications/Music.app"; }
    ];
  };
}
