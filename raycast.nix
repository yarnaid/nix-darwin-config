{ ... }:
let
  scriptsDir = "/Users/yarnaid/.config/raycast-scripts";
in
{
  # Raycast "open project" pipeline. Deployed to a local dir instead of the
  # Dropbox raycast-scripts folder: launchd-spawned processes have no TCC
  # grant for ~/Library/CloudStorage (File Provider) — exec/read/write there
  # fails with EPERM and no prompt. The dropdown data is machine-local
  # anyway, so syncing it via Dropbox would let the two machines clobber
  # each other. Raycast must list this dir in Settings → Extensions → Scripts.

  # Regenerate the dropdown when projects are added or removed.
  # WatchPaths is non-recursive, hence both directory levels.
  launchd.user.agents.regen-project-dropdown = {
    serviceConfig = {
      ProgramArguments = [ "${scriptsDir}/list-projects.sh" ];
      WatchPaths = [
        "/Users/yarnaid/projects"
        "/Users/yarnaid/projects/adnoc"
      ];
      RunAtLoad = true; # актуализация после ребута
      # launchd's default PATH lacks /opt/homebrew/bin (jq, from brew.nix).
      EnvironmentVariables.PATH = "/opt/homebrew/bin:/usr/bin:/bin";
      StandardOutPath = "/tmp/org.nixos.regen-project-dropdown.stdout";
      StandardErrorPath = "/tmp/org.nixos.regen-project-dropdown.stderr";
    };
  };

  home-manager.users.yarnaid =
    { lib, ... }:
    {
      # Read-only scripts: store symlinks.
      home.file.".config/raycast-scripts/list-projects.sh" = {
        source = ./raycast-scripts/list-projects.sh;
        executable = true;
      };
      home.file.".config/raycast-scripts/open-project.applescript" = {
        source = ./raycast-scripts/open-project.applescript;
        executable = true;
      };

      # open-project.sh is mutable state — list-projects.sh sed-rewrites its
      # dropdown line in place — so seed it once instead of symlinking into
      # the read-only store.
      home.activation.seedRaycastOpenProject = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${scriptsDir}"
        if [ ! -e "${scriptsDir}/open-project.sh" ]; then
          cp ${./raycast-scripts/open-project.sh} "${scriptsDir}/open-project.sh"
          chmod 755 "${scriptsDir}/open-project.sh"
        fi
      '';
    };
}
