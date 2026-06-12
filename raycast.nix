{ ... }:
{
  # Regenerate the Raycast project-dropdown list when projects are added or
  # removed. WatchPaths is non-recursive, hence both directory levels.
  launchd.user.agents.regen-project-dropdown = {
    serviceConfig = {
      ProgramArguments = [
        "/Users/yarnaid/Library/CloudStorage/Dropbox/2-Resources/raycast-scripts/list-projects.sh"
      ];
      WatchPaths = [
        "/Users/yarnaid/projects"
        "/Users/yarnaid/projects/adnoc"
      ];
      RunAtLoad = true; # актуализация после ребута
    };
  };
}
