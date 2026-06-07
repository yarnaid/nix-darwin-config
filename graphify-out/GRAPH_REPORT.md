# Graph Report - .  (2026-06-07)

## Corpus Check
- 16 files · ~15,475 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 77 nodes · 91 edges · 10 communities (7 shown, 3 thin omitted)
- Extraction: 86% EXTRACTED · 14% INFERRED · 0% AMBIGUOUS · INFERRED: 13 edges (avg confidence: 0.83)
- Token cost: 195,907 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Homebrew Package Groups|Homebrew Package Groups]]
- [[_COMMUNITY_Activation Scripts & macOS Tweaks|Activation Scripts & macOS Tweaks]]
- [[_COMMUNITY_Brew Bundle Policy & Generator|Brew Bundle Policy & Generator]]
- [[_COMMUNITY_Flake Inputs & Wiring|Flake Inputs & Wiring]]
- [[_COMMUNITY_Nix-to-Chezmoi Migration|Nix-to-Chezmoi Migration]]
- [[_COMMUNITY_System Module Imports|System Module Imports]]
- [[_COMMUNITY_shared.toml Source of Truth|shared.toml Source of Truth]]
- [[_COMMUNITY_Sudoers darwin-rebuild|Sudoers darwin-rebuild]]
- [[_COMMUNITY_TouchID for sudo|TouchID for sudo]]
- [[_COMMUNITY_WezTerm Config|WezTerm Config]]

## God Nodes (most connected - your core abstractions)
1. `Homebrew declarative config (brew.nix)` - 22 edges
2. `configuration.nix (system module)` - 7 edges
3. `postActivation activation script` - 7 edges
4. `nix-to-chezmoi migration design spec` - 7 edges
5. `nix-darwin flake (entry point)` - 5 edges
6. `shared.toml (single source of truth: PATH, env, aliases)` - 5 edges
7. `Mac App Store apps (homebrew.masApps)` - 5 edges
8. `nix-darwin homebrew module (hb2.nix)` - 5 edges
9. `darwinConfigurations (EPGETBIW0286, mpb-14-aum)` - 4 edges
10. `launchd agent proton-pass-agent (ssh-agent)` - 4 edges

## Surprising Connections (you probably didn't know these)
- `dock.nix (persistent-apps layout)` --semantically_similar_to--> `aerospace.nix (tiling WM, disabled)`  [INFERRED] [semantically similar]
  dock.nix → aerospace.nix
- `kanata.nix (launchd daemon keyboard remapper)` --semantically_similar_to--> `ssh2iterm2.nix (user launchd agent syncing ssh config to iTerm2)`  [INFERRED] [semantically similar]
  kanata.nix → ssh2iterm2.nix
- `Homebrew declarative config (brew.nix)` --conceptually_related_to--> `nix-darwin homebrew module (hb2.nix)`  [INFERRED]
  brew.nix → hb2.nix
- `nix-to-chezmoi migration design spec` --references--> `chezmoi (dotfile manager)`  [INFERRED]
  docs/specs/2026-05-31-nix-to-chezmoi-migration.md → brew.nix
- `darwinConfigurations (EPGETBIW0286, mpb-14-aum)` --references--> `configuration.nix (system module)`  [EXTRACTED]
  flake.nix → configuration.nix

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **shared.toml feeds nix PATH/env and rendered shell aliases** — nix_darwin_shared_toml, nix_darwin_env_root, nix_darwin_home_alias_files [EXTRACTED 1.00]
- **Proton Pass CLI ssh-agent: install, launchd agent, socket env, system agent disabled** — nix_darwin_home_proton_pass_cli, nix_darwin_home_proton_pass_agent, nix_darwin_shared_toml_ssh_auth_sock, nix_darwin_configuration_disable_openssh_agent [EXTRACTED 1.00]
- **Spotlight: UI suppressed but indexing kept on for mas** — nix_darwin_configuration_spotlight_ui_suppression, nix_darwin_mas_spotlight_dependency, nix_darwin_configuration_spotlight_exclusions [EXTRACTED 1.00]
- **Homebrew bundle activation flow** — nix_darwin_brew_homebrew_config, nix_darwin_hb2_homebrew_module, nix_darwin_hb2_brew_bundle_activation, nix_darwin_brew_cleanup_zap [INFERRED 0.85]
- **nix-to-chezmoi migration (spec + plan + shared.toml)** — specs_2026_05_31_nix_to_chezmoi_migration_spec, plans_2026_05_31_nix_to_chezmoi_migration_plan, specs_2026_05_31_nix_to_chezmoi_migration_shared_toml, specs_2026_05_31_nix_to_chezmoi_migration_boundary [EXTRACTED 0.90]

## Communities (10 total, 3 thin omitted)

### Community 0 - "Homebrew Package Groups"
Cohesion: 0.13
Nodes (15): GUI casks: browsers (zen, vivaldi, orion, google-chrome), GUI casks: editors & AI tools (cursor, zed, visual-studio-code, sublime-text, claude, codex), GUI casks: local LLM runners (lm-studio, ollama-app), GUI casks: Proton suite (proton-mail, proton-mail-bridge, protonvpn, proton-pass), GUI casks: terminals (ghostty, iterm2, wezterm, warp), GUI casks: window/input utilities (rectangle-pro, bettertouchtool, karabiner-elements, homerow, mos), duti (per-UTI default apps CLI), Git tooling brews (git, gh, lazygit, git-delta, forgit, git-extras) (+7 more)

### Community 1 - "Activation Scripts & macOS Tweaks"
Cohesion: 0.14
Nodes (14): activationScripts fixed phase-name whitelist, defaultFolderHandler (pin Finder for public.folder via duti), disable iStat Menus system daemon, disable macOS built-in OpenSSH agent, NSFileViewer pinned to Finder, force login shell to zsh via dscl, postActivation activation script, Spotlight Privacy exclusions (+6 more)

### Community 2 - "Brew Bundle Policy & Generator"
Cohesion: 0.23
Nodes (12): cleanup = zap policy, --force-cleanup extraFlag (Homebrew 5.x), mas (Mac App Store CLI), nix-darwin repo overview (project CLAUDE.md), Homebrew bundle activation script, Brewfile generator helpers, nix-darwin homebrew module (hb2.nix), Lockfile support removed in Homebrew 4.4.0 (+4 more)

### Community 3 - "Flake Inputs & Wiring"
Cohesion: 0.24
Nodes (10): home-manager integration (useGlobalPkgs, useUserPackages), darwinConfigurations (EPGETBIW0286, mpb-14-aum), home-manager input (release-26.05), nix-darwin input (LnL7/nix-darwin-26.05), nixpkgs input (26.05-darwin), nixpkgs-nixos input (nixos-26.05), pkgs-nixos instantiated package set, nix-darwin flake (entry point) (+2 more)

### Community 4 - "Nix-to-Chezmoi Migration"
Cohesion: 0.28
Nodes (9): chezmoi (dotfile manager), sheldon (zsh plugin manager), Clean-login-shell verification protocol, nix-to-chezmoi migration implementation plan, nix/chezmoi division-of-labor boundary, Per-shell env-bridge (stays nix), shared.toml single source of truth, nix-to-chezmoi migration design spec (+1 more)

### Community 5 - "System Module Imports"
Cohesion: 0.33
Nodes (7): aerospace.nix (tiling WM, disabled), configuration.nix (system module), dock.nix (persistent-apps layout), git configuration (delta, credential helpers), kanata.nix (launchd daemon keyboard remapper), logging.nix (tameUnifiedLog activation script), ssh2iterm2.nix (user launchd agent syncing ssh config to iTerm2)

### Community 6 - "shared.toml Source of Truth"
Cohesion: 0.38
Nodes (7): env.nix (systemPath + variables from shared.toml), rendered shell alias files (~/.config/sh/aliases{,.nu}), nix/chezmoi division of labor, shared.toml (single source of truth: PATH, env, aliases), shared.toml [aliases], shared.toml [env] environment vars, shared.toml [paths] PATH entries

## Knowledge Gaps
- **27 isolated node(s):** `nixpkgs input (26.05-darwin)`, `nix-darwin input (LnL7/nix-darwin-26.05)`, `disable iStat Menus system daemon`, `Spotlight Privacy exclusions`, `TouchID sudo (pam reattach)` (+22 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Homebrew declarative config (brew.nix)` connect `Homebrew Package Groups` to `Brew Bundle Policy & Generator`, `Nix-to-Chezmoi Migration`?**
  _High betweenness centrality (0.178) - this node is a cross-community bridge._
- **Why does `configuration.nix (system module)` connect `System Module Imports` to `Flake Inputs & Wiring`, `shared.toml Source of Truth`?**
  _High betweenness centrality (0.121) - this node is a cross-community bridge._
- **Why does `shared.toml [env] environment vars` connect `shared.toml Source of Truth` to `Activation Scripts & macOS Tweaks`?**
  _High betweenness centrality (0.113) - this node is a cross-community bridge._
- **What connects `nixpkgs input (26.05-darwin)`, `nix-darwin input (LnL7/nix-darwin-26.05)`, `disable iStat Menus system daemon` to the rest of the system?**
  _36 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Homebrew Package Groups` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `Activation Scripts & macOS Tweaks` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._