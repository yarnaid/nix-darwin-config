{ ... }:

{
  home-manager.users.yarnaid = {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices.nas = {
          id = "HIRFCQZ-6ES7TXP-E64MTIP-BRTDXHG-TKCAEHO-QZRHQZZ-ISEHWYX-VDB5CAS";
          addresses = [ "tcp://192.168.0.129:22000" ];
        };
        folders.pictures = {
          path = "/Users/yarnaid/Pictures";
          devices = [ "nas" ];
          type = "sendonly";

          fsWatcherEnabled = true;
          fsWatcherDelayS = 10;
          rescanIntervalS = 3600;

          ignorePerms = false;
        };
      };
    };

    # HM 26.05 syncthing module has no `ignores` option — patterns must live
    # in `.stignore` at the folder root. Leading `/` anchors the pattern to
    # the folder root (otherwise it would match at any depth).
    home.file."Pictures/.stignore".text = ''
      /Photos Library.photoslibrary
    '';
  };
}
