# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

nix-darwin + Home Manager configuration for macOS (aarch64-darwin). Two machine hostnames are defined: `EPGETBIW0286` and `mpb-14-aum`. Both share the same `configuration.nix`.

## Key commands

`darwin-rebuild` does **not** need `sudo` — the nix daemon handles privileged operations internally. If the command is not in PATH (e.g. in a fresh shell), use the full path `/run/current-system/sw/bin/darwin-rebuild`.

```bash
# Rebuild and activate the system (run from /private/etc/nix-darwin)
darwin-rebuild switch --flake .#EPGETBIW0286
darwin-rebuild switch --flake .#mpb-14-aum

# Build without activating (check for errors)
darwin-rebuild build --flake .#EPGETBIW0286

# Update flake inputs
nix flake update

# Check flake without building
nix flake check

# Format nix files
nixfmt-classic *.nix
```

## File layout and responsibilities

| File | Purpose |
| --- | --- |
| `flake.nix` | Entry point. Declares inputs (nixpkgs-unstable, nix-darwin, home-manager, stylix) and `darwinConfigurations` per hostname. |
| `configuration.nix` | System-level config. Imports all other `*.nix` modules. Sets macOS defaults, nix GC/optimise, fish shell, primary user, Home Manager integration. |
| `home.nix` | Home Manager entry point for user `yarnaid`. Imports `fish.nix`. Configures shell aliases, git, bat, btop, atuin, direnv, mise, oh-my-posh, zsh, zellij, yazi, fzf, eza, ruff, etc. |
| `fish.nix` | Fish shell config: PATH fixes for Nix, environment variables, fisher plugins (autopair, done, sponge, zoxide, abbreviation-tips, nvm.fish, foreign-env). |
| `brew.nix` | Homebrew declarative config via nix-darwin. `cleanup = "zap"` means packages not listed here are uninstalled on activation. |
| `mas.nix` | Mac App Store apps via `homebrew.masApps`. |
| `dock.nix` | Declarative Dock layout (`system.defaults.dock.persistent-apps`). |
| `env.nix` | System-wide PATH additions and environment variables (EDITOR, GOPATH, FZF config, HOMEBREW_* flags, etc.). |
| `kanata.nix` | Launchd daemon that runs kanata (keyboard remapper) at boot, reading config from `~/.config/kanata.kbd`. |

## Architecture notes

- All modules are imported by `configuration.nix`; `flake.nix` loads only `configuration.nix` (plus home-manager and stylix darwin modules).
- Home Manager is configured with `useGlobalPkgs = true` and `useUserPackages = true`, so `pkgs` in home modules refers to the system nixpkgs instance.
- Stylix is included as a flake input and loaded as a Darwin module; the monospace font is set to "MonoLiza Nerd Font" in `configuration.nix`.
- `brew.nix` uses `onActivation.cleanup = "zap"` — any Homebrew package installed manually outside this file will be removed on the next `darwin-rebuild switch`.
- Many tools appear in both Homebrew (`brew.nix`) and Home Manager (`home.nix`) with one commented out — the active version controls which package manages the program.
- `kanata` config file lives outside this repo at `~/.config/kanata.kbd` (managed separately, likely via chezmoi).

## Nix channel

Uses `nixpkgs-unstable` for all packages. No stable channel pinning.
