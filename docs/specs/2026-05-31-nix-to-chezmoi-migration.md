# Design: migrate config to chezmoi (incl. shells); nix → packages/system/PATH only

Date: 2026-05-31
Status: approved-design (pending spec review)
Repos: `/private/etc/nix-darwin` (nix), `~/.local/share/chezmoi` (chezmoi)

## Goal

Shrink nix to what genuinely needs it (package orchestration, macOS system state,
PATH/env, the per-shell *env-bridge*). Move ALL user-editable config — including
shell rc files — into chezmoi. One shared file for aliases, loadable by zsh, bash,
fish, and nushell.

## Decisions (anchors)

1. **Packages**: brew/mas first; `home.packages` only for tools absent from brew/mas.
2. **Shells move to chezmoi** (zsh/bash/fish/nu rc + plugin init). Seeded from the
   current *working* generated files, with `/nix/store/...` paths rewritten to bare
   command names (PATH-resolved). Integration evals hand-written + guarded.
3. **PATH stays in nix** `env.nix environment.systemPath` — session-wide (GUI,
   launchd, non-interactive, all shells inherit). NOT moved to a runtime loader
   (that would re-create the interactive-only PATH bug fixed this session).
4. **Aliases: one shared file** `~/.config/sh/aliases` (`name=command` per line).
   Runtime loaders for zsh/bash/fish; nu sources an auto-generated static `aliases.nu`.
5. **System env-bridges stay nix** (they inject nix's PATH/env/NIX_PATH per shell):
   - zsh/bash: `/etc/zshenv` etc. — automatic from nix-darwin.
   - fish: `programs.fish.enable` + `useBabelfish` → `/etc/fish/config.fish` +
     `setEnvironment.fish`. **2 lines, must stay** — fish can't read `/etc/zshenv`;
     this is its only nix-env channel (verified: gives fish PATH + NIX_PATH).
   - nu: inherits PATH from the parent process env (nix systemPath).

## Boundary (end state)

| Concern | Owner |
|---|---|
| Package install | brew/mas, else `home.packages` |
| macOS defaults, launchd (kanata, atuin-daemon), dock, logging, aerospace | nix |
| PATH | nix `env.nix systemPath` |
| Shared non-PATH env vars | nix `env.nix environment.variables` |
| Per-shell env-bridge (fish `programs.fish`; zsh `/etc/zshenv`) | nix |
| Shell rc + plugin init + prompt | **chezmoi** |
| Per-tool plain config files | **chezmoi** |
| Shared aliases (`~/.config/sh/aliases`) + nu-generated `aliases.nu` | **chezmoi** |

nix-darwin after migration ≈ `brew.nix` + `mas.nix` + `configuration.nix`
(system.defaults, programs.fish env-bridge, launchd, activation scripts) +
`env.nix` (systemPath + variables) + `dock.nix`/`logging.nix`/`aerospace.nix`/
`kanata.nix`. home-manager `programs.*` for tools is removed (package via brew).

## Cross-shell aliases (verified mechanism)

Source of truth — `~/.config/sh/aliases` (chezmoi-managed):
```
# name=command   (lines starting with # or blank are skipped)
g=git
gs=git status
ls=eza --color=always --long --git --icons=always --no-permissions --header --mounts --git-repos --hyperlink
l=ls
v=nvim
vim=nvim
y=yazi
b=brew
bs=brew search --desc --eval-all
bi=brew install
bu=brew upgrade -g
cv=chezmoi edit --watch
ca=chezmoi add
cu=chezmoi update
os=ollama serve
```

Loaders (placed in each shell's chezmoi-managed rc):

zsh / bash (POSIX, identical):
```sh
while IFS='=' read -r k v; do case "$k" in ''|\#*) continue;; esac; alias "$k=$v"; done < ~/.config/sh/aliases
```

fish (`alias` creates a function at runtime — works):
```fish
for l in (string match -rv '^#|^$' < ~/.config/sh/aliases)
  set kv (string split -m1 '=' -- $l); alias $kv[1] "$kv[2]"
end
```

nushell — `alias` is a PARSE-TIME keyword; it CANNOT be created in a loop
(verified: `Alias name not supported`). So nu sources a static file:
```nu
source ~/.config/sh/aliases.nu
```
`aliases.nu` is regenerated from `~/.config/sh/aliases` by a chezmoi
`run_onchange_` hook (awk: `k=v` → `alias k = v`), so only the one source file is
hand-edited. (If nu is abandoned, drop this file + hook.)

### Caveats
- The shared file holds only simple `cmd [args]` aliases (render in all shells).
  Pipes/`&&`/complex quoting don't translate to nu/fish uniformly — keep those as
  shell-specific snippets in that shell's rc, not in the shared file.
- Each rendered/loaded set must pass a `fish -c` / `nu -c` smoke test (fish
  reserved words; nu syntax).

## PATH — nix `systemPath` (unchanged)

Session-wide, inherited by all four shells + GUI + non-interactive. The fish
env-bridge and `/etc/zshenv` propagate it. Single source = `env.nix`. No paths
loader file.

## Shells → chezmoi (method)

For each shell (zsh, fish, nu; bash if used):
1. `chezmoi add` the CURRENT generated rc (known-good init order).
2. Rewrite every `/nix/store/...-<tool>/bin/<tool>` → bare `<tool>` (PATH-resolved
   via systemPath/brew). `grep /nix/store` the result — zero matches required, or
   it breaks on the next `nix-collect-garbage`.
3. Replace home-manager auto-wired integration evals with explicit, guarded lines:
   `command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"` (and zoxide,
   atuin, direnv, carapace, fzf, oh-my-posh, sheldon). Guards make a fresh machine
   (tools not yet brew-installed) degrade gracefully instead of erroring.
4. fish: drop the redundant hand nix-env bootstrap (`fenv source /etc/static/bashrc`,
   manual PATH fix) — the system `/etc/fish/config.fish` already does it. Keep only
   user content (plugins, prompt, alias loader, guarded integration evals).
5. Remove `programs.zsh`/`fish.nix`/`programs.nushell` (and the tool modules'
   `enableXIntegration`) from nix. Keep system `programs.fish.enable`.
6. `chezmoi apply`, open a fresh shell, verify init order + tools + aliases.

## Per-tool classification

| Tool | Config → | Package → | Notes |
|---|---|---|---|
| git, bat, btop, eza, ghostty, fastfetch, broot, ranger, ruff, yazi, zellij, uv | chezmoi | brew | plain conf; eza is alias-only |
| atuin, mise, direnv | chezmoi (config) | brew | init eval → chezmoi shell rc (guarded) |
| zoxide, carapace, fzf, sheldon | — (init only) | brew | init eval → chezmoi shell rc; sheldon plugins.toml → chezmoi |
| oh-my-posh | chezmoi (theme json) | brew | init eval → chezmoi shell rc |
| zsh, bash, nushell | chezmoi (rc) | brew/builtin | full move |
| fish | chezmoi (user rc) | brew | system env-bridge stays nix |

## Collision resolution (existing chezmoi ↔ home-manager overlap)

chezmoi already manages `.config/atuin`, `.config/btop`, `.config/fish`,
`.config/ranger`. After migration chezmoi owns all of these — so resolution is:
stop home-manager generating them (remove the `programs.*`), reconcile any
hand-edits in the chezmoi copies, keep the chezmoi files. No more dual ownership.
Flag: vendored `.config/ranger/.../.git` should become a chezmoi `external` or
submodule (separate hygiene task, out of scope).

## Migration order (reversible, verified per step)

1. **Aliases mechanism first**: create `~/.config/sh/aliases` + loaders + nu hook;
   wire into the *current* (still-nix) shell rcs; verify aliases work in all shells.
   Then remove `home.nix shellAliases` + `fish.nix` aliases.
2. **Low-risk tool configs** → chezmoi (git, bat, ghostty, fastfetch, broot, yazi,
   zellij, ruff, uv), package via brew; remove from nix; verify each.
3. **Collision set** (btop, ranger): stop nix generating; chezmoi keeps files.
4. **Split tools** (atuin, mise, direnv): config → chezmoi; init eval stays in rc.
5. **Shells** → chezmoi per the method above (zsh, then fish, then nu). Highest
   risk; do last, one shell at a time, fresh-shell verify between each.
6. Trim nix: remove emptied modules; `darwin-rebuild build` + inspect generated set
   before `switch`.

## Risks & mitigations

- **No atomic rollback** (biggest): `chezmoi apply` + `brew bundle` aren't atomic;
  partial failure = mixed state. Mitigation: migrate incrementally, commit both
  repos per step, keep nix generations until migration proven.
- **Bootstrap order on fresh machine**: brew → `brew bundle` → `chezmoi apply`. The
  guarded integration evals (step 3 above) prevent rc errors when tools aren't yet
  installed. Document the bootstrap sequence in chezmoi README.
- **Store-path staleness**: exhaustive `/nix/store` rewrite in shell rcs (verified
  zero matches) — else breakage after GC.
- **Backup collisions** during HM→chezmoi handoff: file-by-file; rename stale
  `<f>.backup` first.
- **Re-breaking shell init**: seed from working generated files; verify init order in
  a fresh shell after each shell migrates.

## Out of scope

- Moving PATH to a runtime loader (kept in nix systemPath, by decision).
- Removing the fish system env-bridge (`programs.fish`) — required.
- Secret management (keychain; never in dotfiles or nix store).
- `.config/ranger/.../.git` vendoring cleanup.
