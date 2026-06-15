{ ... }:

{
  home-manager.users.yarnaid = {
    services.syncthing = {
      enable = true;
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices.nas = {
          id = "TPM43DV-VGRA5G7-2NS7RPZ-7S2VAEU-7IB3GAC-5VSYHIO-QHSSPXI-XKPPMQX";
          addresses = [ "tcp://192.168.0.129:22000" ];
        };
        folders.pictures = {
          path = "/Users/yarnaid/Pictures/active";
          devices = [ "nas" ];
          type = "sendonly";

          fsWatcherEnabled = true;
          fsWatcherDelayS = 10;
          rescanIntervalS = 3600;

          ignorePerms = false;

          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "31536000";
            };
          };
        };
      };
    };
  };
}
