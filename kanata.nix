{config, lib, pkgs, ...}: {
  launchd.daemons = {
    kanata = {
      serviceConfig = {
        KeepAlive = true;
        Label = "kanata";
        ProgramArguments = [
          "${config.homebrew.brewPrefix}/kanata"
          "--cfg"
          "/Users/yarnaid/.config/kanata.kbd"
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/local.job.stderr";
        StandardOutPath = "/tmp/local.job.stdout";
      };
    };
  };
} 
