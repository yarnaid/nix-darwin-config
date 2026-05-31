# Design: migrate per-tool config from nix → chezmoi; unify cross-shell aliases

Date: 2026-05-31
Status: approved-design (pending spec review)
Repos touched: `/private/etc/nix-darwin` (nix), `~/.local/share/chezmoi` (chezmoi)

## Goal

Reduce nix's surface to what genuinely needs it. Move every tool config that is
expressible as a plain conf file into chezmoi. Keep only shared/system concerns
in nix. Provide one source of truth for shell aliases usable across zsh, bash,
fish, and nushell despite their incompatible syntax.

## Decisions (anchors)

1. **Packages**: brew/mas first; `home.packages` only for tools not in brew/mas.
2. **Shared mechanism**: PATH stays in nix `environment.systemPath` (inherited by
   all shells — no per-shell syntax, no login/non-login drift). Aliases live once
   in chezmoi `.chezmoidata.toml` and are rendered per-shell by chezmoi templates.
3. **Shells stay in nix**: `programs.zsh`, `fish.nix`, `programs.nushell` keep
   generating shell rc + plugin init order (just stabilised this session).
4. **Split pattern**: a tool with BOTH a plain config file AND a shell-init hook
   splits — config file → chezmoi, init line → nix. (Decided for atuin; applies to
   mise and direnv too.)

## Boundary

| Concern | Owner |
|---|---|
| Package install | brew/mas, else `home.packages` (nix) |
| macOS defaults, launchd, dock, logging, aerospace | nix |
| PATH | nix `env.nix` `environment.systemPath` |
| Shared env vars | nix `env.nix` `environment.variables` |
| Shell rc + plugin init order (zsh/fish/nu) | nix |
| Shell-integration init lines (atuin/zoxide/mise/direnv/carapace/sheldon/oh-my-posh) | nix |
| Per-tool plain config files | chezmoi |
| Alias source of truth + rendered per-shell files | chezmoi |

## Per-tool classification (21 `programs.*` + fish.nix)

| Tool | Has plain config? | Shell-init hook? | Action |
|---|---|---|---|
| git | yes (.config/git/config) | no | → chezmoi (full) |
| bat | yes | no | → chezmoi (full) |
| btop | yes (**chezmoi already mgmt**) | no | → chezmoi; remove from home-manager |
| eza | flags only (alias) | no | flags → alias data file; no separate file |
| ghostty | yes | no | → chezmoi (full) |
| fastfetch | yes (config.jsonc) | no | → chezmoi (full) |
| broot | yes | no | → chezmoi (full) |
| ranger | yes (**chezmoi already mgmt**) | no | → chezmoi; remove from home-manager |
| ruff | yes (global ruff) | no | → chezmoi (full) |
| yazi | yes | no | → chezmoi (full) |
| zellij | yes (config.kdl) | no | → chezmoi (full) |
| uv | yes (~/.config/uv) | no | → chezmoi (full) |
| atuin | yes (config.toml, **chezmoi mgmt .config/atuin**) | yes (`atuin init`) | **split**: config→chezmoi, init→nix |
| mise | yes (config.toml) | yes (`mise activate`) | **split**: config→chezmoi, activate→nix |
| direnv | yes (direnvrc) | yes (`direnv hook`) | **split**: direnvrc→chezmoi, hook→nix |
| fzf | env vars only (in env.nix) | yes (`fzf --zsh`) | stays nix (env + init); no chezmoi file |
| carapace | no real config | yes | stays nix |
| zoxide | no (`--cmd cd` flag only) | yes | stays nix |
| sheldon | plugins.toml (drives zsh init order) | drives init | stays nix |
| zsh | shell | — | stays nix |
| nushell | shell | — | stays nix |
| fish (fish.nix) | shell (**chezmoi mgmt .config/fish**) | — | stays nix; `chezmoi forget .config/fish` |

## Shared aliases mechanism

Source of truth — `~/.local/share/chezmoi/.chezmoidata.toml`:

```toml
[aliases]            # cross-shell, plain "cmd [args]" form (renders cleanly everywhere)
g  = "git"
gs = "git status"
gp = "git push"
gl = "git pull"
ls = "eza --color=always --long --git --icons=always --no-permissions --header --mounts --git-repos --hyperlink"
l  = "ls"
ll = "ls -la"
v  = "nvim"
vim = "nvim"
y  = "yazi"
os = "ollama serve"
b  = "brew"
bs = "brew search --desc --eval-all"
bi = "brew install"
bu = "brew upgrade -g"
cv = "chezmoi edit --watch"
ca = "chezmoi add"
cu = "chezmoi update"

[aliases_only.zsh]   # optional: entries valid only in a given shell
# ".." handled natively (zsh has `..` via setopt autocd / abbrev), etc.
```

chezmoi templates (one per shell) render the data into shell-correct files:

| Template (chezmoi source) | Renders to | Per-entry syntax |
|---|---|---|
| `dot_config/sh/aliases.zsh.tmpl` | `~/.config/sh/aliases.zsh` | `alias g='git'` |
| `dot_config/sh/aliases.bash.tmpl` | `~/.config/sh/aliases.bash` | `alias g='git'` |
| `dot_config/fish/conf.d/aliases.fish.tmpl` | `~/.config/fish/conf.d/aliases.fish` | `alias g 'git'` |
| `dot_config/sh/aliases.nu.tmpl` | `~/.config/sh/aliases.nu` | `alias g = git` |

Template body (zsh/bash example):
```
{{ range $k, $v := .aliases }}alias {{ $k }}={{ $v | quote }}
{{ end }}
```

Sourcing wiring (added to the nix-generated shell rc — ONE line each):
- **zsh** (`programs.zsh.initContent`): `[ -f ~/.config/sh/aliases.zsh ] && source ~/.config/sh/aliases.zsh`
- **bash**: same in bashrc.
- **fish**: file lands in `~/.config/fish/conf.d/` → auto-sourced (no wiring needed). But `.config/fish` is nix-owned (shell) → place the rendered file via fish's `conf.d` which fish auto-loads regardless of owner; chezmoi writes only this one file there, nix owns the rest.
- **nushell** (`programs.nushell` config): `source ~/.config/sh/aliases.nu`

Removals: delete `home.nix programs.zsh.shellAliases` and `fish.nix` alias/abbr
definitions — they move into `.chezmoidata.toml`.

### Syntax caveats
- nushell aliases can't express every zsh alias (pipes, `&&`, complex quoting).
  The `[aliases]` table holds only simple `cmd [args]` forms that render in all
  four shells. Shell-specific complex aliases go in `[aliases_only.<shell>]` and
  render only into that shell's file.
- fish reserves some builtins (e.g. can't `alias ls` to wrap `ls` recursively the
  same way) — verify each renders without `alias: cannot ...` on `fish -c`.

## PATH — unchanged

Stays `env.nix environment.systemPath`. Rationale: nix-darwin sets it in the
inherited process environment (via the set-environment file `/etc/zshenv`
sources), so all four shells get it for free with zero per-shell syntax. Moving
it to chezmoi would re-introduce per-shell PATH snippets and the login/non-login
divergence fixed earlier this session.

## Collision resolution (existing chezmoi ↔ home-manager overlap)

chezmoi currently manages `.config/atuin`, `.config/btop`, `.config/fish`,
`.config/ranger`. Resolve to one owner each:
- **btop, ranger** → chezmoi wins: stop home-manager generating their config
  (keep `programs.X.enable` only if needed for the package, else install via
  brew). chezmoi keeps the existing files.
- **fish** → nix wins (it's a shell): `chezmoi forget ~/.config/fish` EXCEPT the
  single `conf.d/aliases.fish` rendered file. Reconcile any hand-edits in the
  chezmoi copy into fish.nix first.
- **atuin** → split: chezmoi keeps `config.toml`; nix keeps the `atuin init` line.
  Remove atuin `settings` from `programs.atuin` (keep `enable` for the daemon +
  init), let chezmoi own config.toml.
- Nested git repo `.config/ranger/plugins/ranger_devicons/.git` is committed into
  chezmoi — flag: should be a submodule or chezmoi `external`, not a vendored
  `.git`. Out of scope for this migration; note for cleanup.

## Migration procedure (per tool — reversible + verified)

For each tool moving to chezmoi:
1. Capture the current home-manager-generated config (`cat` the live file).
2. `chezmoi add ~/.config/<tool>/<file>` (or author the template) with identical
   content.
3. Remove the config-generating bits from the nix module (keep package install
   per the brew/mas-first rule).
4. `chezmoi apply` then `darwin-rebuild switch`.
5. Verify the tool still reads its config (`<tool> --version` / a config-dependent
   command; e.g. `bat --config-file`, `btop` starts, `git config --list`).
6. Commit both repos.

Order: low-risk plain-conf tools first (git, bat, ghostty, fastfetch, broot,
yazi, zellij, ruff, uv), then the collision set (btop, ranger), then the splits
(atuin, mise, direnv), then wire up the alias mechanism, last remove the nix
alias definitions.

## Risks & mitigations

- **Double-write race** (both nix + chezmoi write a file): always remove the nix
  side in the same step as adding the chezmoi side; `darwin-rebuild build` then
  inspect the generated file set before `switch`.
- **home-manager backup collisions** (`backupFileExtension`): if HM tries to back
  up a file chezmoi now owns, rename stale `<f>.backup` first (known gotcha).
- **Re-breaking shells**: shells stay in nix → init order untouched. Only a single
  `source aliases.<shell>` line is added; guarded with `[ -f ]`.
- **chezmoi/nix apply ordering**: `chezmoi apply` and `darwin-rebuild switch` are
  independent; a tool's config (chezmoi) and its package (nix/brew) can land in
  either order — both must be idempotent. Acceptable (config readable once both ran).

## Out of scope / deferred

- Moving shells (zsh/fish/nu) themselves to chezmoi — explicitly kept in nix.
- Moving PATH to chezmoi — kept in nix.
- Cleaning the vendored `.config/ranger/.../.git` (separate hygiene task).
- Secret management (handled separately: keychain, not dotfiles).
