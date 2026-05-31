{ ... }:
let
  # Single source of truth for PATH + env (and aliases, read by home.nix).
  shared = builtins.fromTOML (builtins.readFile ./shared.toml);
in
{
  # PATH + env are driven by shared.toml so one file feeds every shell.
  environment.systemPath = shared.paths.entries;
  environment.variables = shared.env;
}
