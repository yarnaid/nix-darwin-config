{ config, lib, pkgs, ... }:

{
  system.defaults.dock = {
    persistent-apps = [
      { app = "/Applications/Safari.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Microsoft Outlook.app"; }
      { app = "/Applications/Setapp/Spark Mail.app"; }
      { app = "/Applications/Telegram.app"; }
      { app = "/Applications/Microsoft Teams (work or school).app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Windows App.app"; }
      { app = "/Applications/WezTerm.app"; }
      { app = "/Applications/Cursor.app"; }
      { app = "/Applications/Visual Studio Code.app"; }
      { spacer = { small = true; }; }
      { app = "/System/Applications/System Settings.app"; }
      { app = "/System/Applications/Utilities/Activity Monitor.app"; }
      { spacer = { small = true; }; }
      { app = "/Applications/Things3.app"; }
      { app = "/Applications/Tana.app"; }
      { app = "/System/Applications/iPhone Mirroring.app"; }
      { app = "/Applications/Parcel.app"; }
      { app = "/Applications/Deezer.app"; }
    ];
  };
}
