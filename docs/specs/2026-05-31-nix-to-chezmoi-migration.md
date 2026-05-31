# Design: migrate config to chezmoi; one shared.toml drives PATH/env/aliases

Date: 2026-05-31
Status: approved-design (pending final spec review)
Repos: `/private/etc/nix-darwin` (nix), `~/.local/share/chezmoi` (chezmoi)

## Goal

Shrink nix to package orchestration + macOS system state + the per-shell
env-bridge. Move all user-editable config — including shell rc files — to chezmoi.
A single `shared.toml` is the one source of truth for PATH, env vars, and aliases
across zsh, fish, and nushell.

## Decisions (anchors)

1. **Packages**: brew/mas first; `home.packages` only when absent from brew/mas.
2. **Shells → chezmoi** (zsh, fish, nu). **bash is scripting-only — no interactive
   rc / no loader.** Seed from working generated rc; rewrite `/nix/store/...` →
   bare command names; integration evals hand-written + guarded.
3. **One shared data file** `/private/etc/nix-darwin/shared.toml` (data, not nix
   code):
   - `[paths]` → nix `environment.systemPath` (session-wide — the only mechanism
     here, since nix-darwin doesn't run `path_helper`).
   - `[env]` → nix `environment.variables` (session-wide).
   - `[aliases]` → nix renders `~/.config/sh/aliases` + `~/.config/sh/aliases.nu`
     (nix natively parses TOML → no parser dependency; regenerates on the same
     `switch` that applies paths/env).
   Lives in the nix repo because flakes are pure — nix cannot read a chezmoi file.
4. **Plugins stay in per-shell native managers**, all configs in chezmoi:
   - zsh → **sheldon**, `~/.config/sheldon/zsh.toml` (sheldon has `--config-file`;
     **sheldon supports only zsh/bash** — verified).
   - fish → **fisher**, `~/.config/fish/fish_plugins`.
   - nu → native modules/overlays.
5. **System env-bridges stay nix** (inject nix PATH/env/NIX_PATH per shell):
   zsh/bash `/etc/zshenv` (automatic); fish `programs.fish.enable` + `useBabelfish`
   → `/etc/fish/config.fish` (2 lines, required — fish can't read `/etc/zshenv`);
   nu inherits via process env.

## Boundary (end state)

| Concern | Owner |
|---|---|
| Package install | brew/mas, else `home.packages` |
| macOS defaults, launchd, dock, logging, aerospace | nix |
| `shared.toml` (paths/env/aliases data) | nix repo (edited by hand) |
| PATH + env vars (from `shared.toml`) | nix `env.nix` reads it |
| `~/.config/sh/aliases{,.nu}` (rendered from `[aliases]`) | nix `home.file` |
| Per-shell env-bridge (fish `programs.fish`, zsh `/etc/zshenv`) | nix |
| Shell rc + prompt + integration evals + plugin-manager source line | **chezmoi** |
| Plugin lists (`zsh.toml`, `fish_plugins`, nu modules) | **chezmoi** |
| Per-tool plain config files | **chezmoi** |

## shared.toml mechanism

```toml
# /private/etc/nix-darwin/shared.toml — single source of truth
[paths]
entries = [
  "/Users/yarnaid/.local/bin", "/opt/homebrew/bin", "/opt/homebrew/sbin",
  "/Users/yarnaid/.cargo/bin", "/Applications/Postgres.app/Contents/Versions/17/bin",
  # ... (migrated from env.nix systemPath)
]
[env]
EDITOR = "nvim"
VISUAL = "nvim"
PAGER = "bat"
# ... (migrated from env.nix environment.variables)
[aliases]
g = "git"
gs = "git status"
ls = "eza --color=always --long --git --icons=always --no-permissions --header --mounts --git-repos --hyperlink"
l = "ls"
v = "nvim"
vim = "nvim"
y = "yazi"
b = "brew"
bs = "brew search --desc --eval-all"
bi = "brew install"
bu = "brew upgrade -g"
cv = "chezmoi edit --watch"
ca = "chezmoi add"
cu = "chezmoi update"
os = "ollama serve"
```

nix side (`env.nix`):
```nix
let shared = builtins.fromTOML (builtins.readFile ./shared.toml);
    toAliasLine = k: v: "alias ${k}=${lib.escapeShellArg v}";
    toNuLine    = k: v: "alias ${k} = ${v}";
in {
  environment.systemPath = shared.paths.entries;
  environment.variables  = shared.env;
  home.file.".config/sh/aliases".text =
    lib.concatStringsSep "\n" (lib.mapAttrsToList toAliasLine shared.aliases);
  home.file.".config/sh/aliases.nu".text =
    lib.concatStringsSep "\n" (lib.mapAttrsToList toNuLine shared.aliases);
}
```
(`home.file` is in a home-manager module; `environment.*` in the darwin module —
both read the same `shared`.)

Shells source the rendered files (chezmoi-owned rc):
- **zsh** (`.zshrc`): `[ -f ~/.config/sh/aliases ] && source ~/.config/sh/aliases`
- **fish** (`config.fish` or `conf.d/`): `test -f ~/.config/sh/aliases; and source ~/.config/sh/aliases` — NOTE: zsh/fish share the POSIX `alias k=v` syntax for *simple* aliases; verify each renders cleanly under fish (`fish -c`). Complex ones go in the shell's own rc.
- **nu** (`config.nu`): `source ~/.config/sh/aliases.nu` (nu `alias` is parse-time —
  verified it can't loop-load; the static rendered file is required).

PATH stays session-wide (nix), so no runtime path loader in any shell.

## Shells → chezmoi (method)

Per shell (zsh, fish, nu):
1. `chezmoi add` the current generated rc (known-good order).
2. Rewrite every `/nix/store/...-<tool>/bin/<tool>` → bare `<tool>`. `grep /nix/store`
   → zero matches (else breaks on GC).
3. Integration evals explicit + guarded, e.g.:
   `command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"` (zoxide, atuin,
   direnv, carapace, fzf, oh-my-posh).
4. Plugin manager source line:
   - zsh: `eval "$(sheldon --config-file ~/.config/sheldon/zsh.toml source)"` (last,
     after autosuggestions per fast-syntax-highlighting ordering).
   - fish: fisher auto-sources from `fish_plugins`; nothing to wire.
5. fish: drop the redundant hand nix-env bootstrap (system `/etc/fish/config.fish`
   already provides it); keep only user content.
6. Remove `programs.zsh`/`fish.nix`/`programs.nushell` + tool `enableXIntegration`
   from nix. Keep system `programs.fish.enable`.
7. `chezmoi apply`, fresh shell, verify init order + tools + aliases.

## Per-tool classification

| Tool | Config → | Package → | Init/notes |
|---|---|---|---|
| git, bat, btop, eza, ghostty, fastfetch, broot, ranger, ruff, yazi, zellij, uv | chezmoi | brew | plain conf; eza alias-only |
| atuin, mise, direnv | chezmoi (config) | brew | init eval → chezmoi rc (guarded) |
| oh-my-posh | chezmoi (theme json) | brew | init eval → chezmoi rc |
| zoxide, carapace, fzf | — | brew | init eval → chezmoi rc |
| sheldon | `zsh.toml` → chezmoi | brew | zsh plugin manager |
| fisher plugins | `fish_plugins` → chezmoi | (fisher) | fish plugin manager |
| zsh, nushell | rc → chezmoi | brew/builtin | full move |
| fish | user rc → chezmoi | brew | system env-bridge stays nix |
| bash | none (scripting only) | builtin | no interactive rc / loader |

## Collision resolution

chezmoi already manages `.config/atuin`, `.config/btop`, `.config/fish`,
`.config/ranger`. After migration chezmoi owns these: stop home-manager generating
them, reconcile hand-edits, keep chezmoi files. The vendored
`.config/ranger/.../.git` → chezmoi `external`/submodule (separate hygiene task).

## Migration order (reversible, verified per step)

1. **shared.toml + alias rendering**: create `shared.toml` (seed paths/env from
   env.nix, aliases from home.nix `shellAliases` + fish), wire nix to read it
   (`fromTOML`), render `~/.config/sh/aliases{,.nu}`. Add the source line to the
   *current* (still-nix) rcs. Verify aliases + PATH + env in all shells. Then
   delete `env.nix` literal systemPath/variables and `home.nix shellAliases` +
   fish aliases.
2. **Low-risk tool configs** → chezmoi (git, bat, ghostty, fastfetch, broot, yazi,
   zellij, ruff, uv); package via brew; remove from nix; verify each.
3. **Collision set** (btop, ranger): stop nix generating; chezmoi keeps files.
4. **Split tools** (atuin, mise, direnv): config → chezmoi; init eval in rc.
5. **Plugins**: `zsh.toml` (sheldon) + `fish_plugins` (fisher) → chezmoi.
6. **Shells** → chezmoi (zsh, then fish, then nu), one at a time, fresh-shell verify
   between each.
7. Trim nix; `darwin-rebuild build` + inspect generated set before `switch`.

## Risks & mitigations

- **No atomic rollback**: `chezmoi apply` + `brew bundle` aren't atomic. Migrate
  incrementally, commit both repos per step, keep nix generations until proven.
- **Bootstrap order (fresh machine)**: brew → `brew bundle` → `chezmoi apply`.
  Guarded integration evals prevent rc errors before tools exist. Document the
  sequence in a chezmoi README.
- **Store-path staleness**: exhaustive `/nix/store` rewrite in rcs (verify zero).
- **shared.toml is in nix → editing aliases needs a `switch`**: accepted — editing
  paths/env needs it anyway; one edit, one rebuild updates everything.
- **fish alias syntax**: smoke-test rendered `aliases` under `fish -c`; move
  non-portable ones to the shell's own rc.
- **Backup collisions** on HM→chezmoi handoff: file-by-file; rename stale
  `<f>.backup` first.

## Out of scope

- Moving PATH/env to a runtime loader (kept session-wide via nix, by decision).
- Removing the fish system env-bridge (`programs.fish`) — required.
- Secret management (keychain; never in dotfiles or nix store).
- `.config/ranger/.../.git` vendoring cleanup.
