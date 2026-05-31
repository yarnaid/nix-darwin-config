# nix → chezmoi Migration Implementation Plan

> **For agentic workers:** execute task-by-task; verify each before the next. Steps use `- [ ]`.

**Goal:** Move all user config (incl. shells) to chezmoi; reduce nix to packages(brew/mas-first)+macOS+launchd+per-shell env-bridge; drive PATH/env/aliases from one `shared.toml`.

**Architecture:** `shared.toml` (nix repo) → nix reads `[paths]`/`[env]` (session-wide) + renders `~/.config/sh/aliases{,.nu}` from `[aliases]`. chezmoi owns tool configs + shell rcs (which source the alias files). Packages via brew/mas. Spec: `docs/specs/2026-05-31-nix-to-chezmoi-migration.md`.

**Tech Stack:** nix-darwin, home-manager, chezmoi v2.70, brew, sheldon (zsh), fisher (fish).

**Safety:** commit both repos per task; `darwin-rebuild build` before every `switch`; verify in a CLEAN login shell (`env -i HOME=$HOME USER=$USER SHELL=/run/current-system/sw/bin/zsh zsh -lic '...'`); keep nix generations until done. Halt+report on any failed verification.

---

## Phase 0: Prep

- [ ] **0.1** Confirm clean-ish state + snapshot.
  Run: `cd /private/etc/nix-darwin && git status --short && darwin-rebuild build --flake .#EPGETBIW0286 && echo BUILD_OK`
  Expected: builds; note current generation (`darwin-rebuild --list-generations | tail -1`).
- [ ] **0.2** Capture current generated artifacts to compare against (reference, not committed):
  `cp ~/.zshrc /tmp/mig/zshrc.orig; cp -r ~/.config/fish /tmp/mig/fish.orig; chezmoi managed > /tmp/mig/chezmoi.before`

## Phase 1: shared.toml + alias rendering (foundation)

**Files:** Create `shared.toml`; Modify `env.nix`, `home.nix`.

- [ ] **1.1** Create `/private/etc/nix-darwin/shared.toml` with `[paths]` (copy current `env.nix` systemPath entries), `[env]` (copy current `env.nix` variables), `[aliases]` (copy `home.nix` shellAliases simple ones; omit `".."`).
- [ ] **1.2** Rewrite `env.nix` to read it:
  ```nix
  { lib, ... }:
  let shared = builtins.fromTOML (builtins.readFile ./shared.toml);
  in {
    environment.systemPath = shared.paths.entries;
    environment.variables = shared.env;
  }
  ```
- [ ] **1.3** In `home.nix`, render the alias files from the same source:
  ```nix
  # near top, after `let`/in a `let` block:
  #   shared = builtins.fromTOML (builtins.readFile ./shared.toml);
  home.file.".config/sh/aliases".text =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k}=${lib.escapeShellArg v}") shared.aliases) + "\n";
  home.file.".config/sh/aliases.nu".text =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "alias ${k} = ${v}") shared.aliases) + "\n";
  ```
- [ ] **1.4** Add source line to current (still-nix) zsh init (`home.nix programs.zsh.initContent`, in the mkMerge head block):
  `[ -f "$HOME/.config/sh/aliases" ] && source "$HOME/.config/sh/aliases"`
  And fish (`fish.nix interactiveShellInit`): `test -f $HOME/.config/sh/aliases; and source $HOME/.config/sh/aliases`
- [ ] **1.5** Remove `home.nix shellAliases` block AND `fish.nix` alias/abbr defs (now sourced from shared).
- [ ] **1.6** `nixfmt *.nix` → `darwin-rebuild build` → `switch`.
  Run: `nixfmt env.nix home.nix shared.toml 2>/dev/null; sudo darwin-rebuild switch --flake .#EPGETBIW0286`
- [ ] **1.7** Verify (clean login zsh + fish):
  `env -i HOME=$HOME USER=$USER SHELL=/run/current-system/sw/bin/zsh zsh -lic 'alias g; echo $PATH | tr : "\n" | grep -c /opt/homebrew/bin; echo $EDITOR'` → `g='git'`, `1`, `nvim`.
  `fish -lc 'alias g; functions g'` → defined.
  Expected: aliases work in both; PATH+env intact.
- [ ] **1.8** Commit nix: `git add -A && git commit -m "feat(shell): single shared.toml drives PATH/env/aliases"`.

## Phase 2: low-risk tool configs → chezmoi + brew

Pattern PER TOOL (exact values in table below):
1. Capture current generated config: `cat <live-config-path>` (note content).
2. Add to chezmoi: `chezmoi add <live-config-path>` (chezmoi copies the live, nix-generated file into its source).
3. Add package to `brew.nix` `casks`/`brews` (if not already): add `<brew-name>` to the appropriate list.
4. Remove the tool's `programs.<tool>` block from `home.nix` (keep nothing — package now via brew).
5. `darwin-rebuild build` → confirm the live config file is now UNMANAGED by nix (chezmoi owns it) → `chezmoi apply` (no-op, already present) → `switch`.
6. Verify the tool still reads config (table).
7. Commit both repos.

| Tool | live config path | brew name | verify command |
|---|---|---|---|
| git | `~/.config/git/config` (or `~/.gitconfig`) | (git via brew) | `git config --get core.pager` → `delta` |
| bat | `~/.config/bat/config` | bat | `bat --config-file && bat --theme` shows TwoDark |
| ghostty | `~/.config/ghostty/config` | ghostty (cask) | `ghostty +show-config` reads it |
| fastfetch | `~/.config/fastfetch/config.jsonc` | fastfetch | `fastfetch --version`; runs |
| broot | `~/.config/broot/conf.toml` | broot | `broot --version` |
| yazi | `~/.config/yazi/*` | yazi | `yazi --version` |
| zellij | `~/.config/zellij/config.kdl` | zellij | `zellij setup --check` |
| ruff | `~/.config/ruff/ruff.toml` (or pyproject) | ruff (via mise/brew) | `ruff --version`; `ruff check --show-settings` |
| uv | `~/.config/uv/uv.toml` | uv (via mise/brew) | `uv --version` |
| eza | (alias only — already in shared.toml) | eza | `alias ls` resolves |

Note: git/ruff/uv may have no separate file if config is inline — if `programs.X` only set settings with no file, author the file from the settings, then `chezmoi add`.

## Phase 3: collision set (btop, ranger) — chezmoi already manages

- [ ] **3.1** Confirm chezmoi already owns `.config/btop`, `.config/ranger` (`chezmoi managed | grep -E 'btop|ranger'`).
- [ ] **3.2** Reconcile: diff chezmoi source vs current live (`chezmoi diff ~/.config/btop`); if nix-generated content differs from chezmoi's, decide chezmoi wins (re-`chezmoi add` if needed).
- [ ] **3.3** Remove `programs.btop`, `programs.ranger` from `home.nix`; ensure `btop`/`ranger` in `brew.nix`.
- [ ] **3.4** build → switch → `chezmoi apply` → verify `btop --version`, `ranger --version`, config present.
- [ ] **3.5** Commit both.

## Phase 4: split tools (atuin, mise, direnv) — config→chezmoi, init→rc

- [ ] **4.1** atuin: `chezmoi add ~/.config/atuin/config.toml`; remove `settings` from `programs.atuin` (keep `enable` + daemon + the launchd override). Keep `atuin init zsh` — it stays in the (still-nix-for-now) zsh init until Phase 6. Ensure atuin in brew. build→switch→verify `atuin --version` + config present + history works.
- [ ] **4.2** mise: `chezmoi add ~/.config/mise/config.toml`; remove `globalConfig` from `programs.mise` (keep enable for activate, or move activate to rc in Phase 6). mise in brew. Verify `mise ls`, `mise doctor`.
- [ ] **4.3** direnv: move `stdlib` (the pass-cli helpers) to chezmoi `~/.config/direnv/direnvrc`; `chezmoi add` it; remove `stdlib` from `programs.direnv` (keep enable for hook until Phase 6). Verify `direnv version`, a test `.envrc` loads.
- [ ] **4.4** Commit both per tool.

## Phase 5: plugins → chezmoi

- [ ] **5.1** zsh/sheldon: `cp ~/.config/sheldon/plugins.toml` content → author `~/.config/sheldon/zsh.toml` (same `shell="zsh"` + plugins); `chezmoi add ~/.config/sheldon/zsh.toml`. (Keep `plugins.toml` until Phase 6 switches the source line.)
- [ ] **5.2** fish/fisher: `chezmoi add ~/.config/fish/fish_plugins` (current fisher plugin list from fish.nix). Verify `fisher list`.
- [ ] **5.3** Commit chezmoi.

## Phase 6: shells → chezmoi (one at a time; HIGHEST RISK)

### 6a zsh
- [ ] **6a.1** `chezmoi add ~/.zshrc` (captures current working generated rc).
- [ ] **6a.2** In the chezmoi `~/.zshrc` source: rewrite every `/nix/store/...-<tool>/bin/<tool>` → bare `<tool>`. Verify: `grep -c /nix/store <chezmoi-source-zshrc>` → 0.
- [ ] **6a.3** Replace auto-wired evals with guarded explicit ones:
  `command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"` (+ zoxide `--cmd cd`, atuin, direnv hook, carapace, fzf, oh-my-posh). sheldon: `command -v sheldon >/dev/null 2>&1 && eval "$(sheldon --config-file ~/.config/sheldon/zsh.toml source)"` (placed per fast-syntax-highlighting order). Keep `source ~/.config/sh/aliases` + zoxide `--cmd cd` LAST.
- [ ] **6a.4** Remove `programs.zsh` + tool `enableZshIntegration` from `home.nix`; remove `programs.zoxide`/`programs.carapace`/`programs.fzf`/`programs.sheldon`/`programs.atuin`(init)/`programs.mise`(activate)/`programs.direnv`(hook)/`programs.oh-my-posh` zsh-integration. Ensure all these tools are in brew.
- [ ] **6a.5** build → switch → `chezmoi apply`. Verify CLEAN login zsh: `env -i HOME=$HOME USER=$USER SHELL=/run/current-system/sw/bin/zsh zsh -lic 'command -v nvim mise zoxide atuin oh-my-posh sheldon; alias g; cd /tmp; cd -'` → all resolve, aliases work, cd(zoxide) works, prompt loads, NO errors/widget-warnings.
- [ ] **6a.6** Commit both.

### 6b fish
- [ ] **6b.1** `chezmoi add ~/.config/fish/config.fish` (+ conf.d as needed).
- [ ] **6b.2** Drop redundant nix-env bootstrap lines (system `/etc/fish/config.fish` provides them); keep user content + fisher + `source ~/.config/sh/aliases` + guarded integration evals (fish syntax).
- [ ] **6b.3** Remove `fish.nix` from `home.nix` imports + delete its home-manager content (KEEP system `programs.fish.enable`/`useBabelfish` in configuration.nix).
- [ ] **6b.4** build → switch → `chezmoi apply`. Verify: `fish -lc 'command -v nvim mise; alias g; echo $PATH | string match -q "*/opt/homebrew/bin*"; and echo PATH_OK; echo $NIX_PATH'` → tools resolve, alias, PATH_OK, NIX_PATH set.
- [ ] **6b.5** Commit both.

### 6c nu
- [ ] **6c.1** `chezmoi add ~/.config/nushell/config.nu ~/.config/nushell/env.nu`.
- [ ] **6c.2** Add: PATH from process env (inherited — verify), `source ~/.config/sh/aliases.nu`, guarded integration evals (nu syntax) for the tools nu uses.
- [ ] **6c.3** Remove `programs.nushell` from `home.nix`. nu in brew.
- [ ] **6c.4** build → switch → `chezmoi apply`. Verify: `nu -c 'which nvim; g --version | lines | first'` (g alias) → resolves.
- [ ] **6c.5** Commit both.

## Phase 7: trim + final verify

- [ ] **7.1** Remove now-empty modules / dead imports from `home.nix`. Confirm remaining nix surface = brew/mas + configuration.nix(system+programs.fish) + env.nix(shared reader) + dock/logging/aerospace/kanata + home.nix(packages-fallback + shared alias render + launchd atuin-daemon).
- [ ] **7.2** `darwin-rebuild build` → inspect generated set has no stray tool configs → `switch`.
- [ ] **7.3** Full smoke: open real zsh, fish, nu tabs; run a few aliases, `cd`, a brew tool, a nix tool; confirm prompt + history + completions.
- [ ] **7.4** `chezmoi managed` diff vs before (new configs present). Commit both repos. Push.
- [ ] **7.5** Update `CLAUDE.md` (project) + `docs/specs/...` status → done. Update `~/.claude/rules/macos-darwin.md` memory if new gotchas surfaced.

## Self-review notes

- Spec coverage: phases map 1:1 to spec sections (shared.toml=§shared.toml; phases 2-6=§per-tool+shells; §collision=phase3; §risks=safety+verify-each).
- Rollback: every task commits both repos; nix generations retained; `chezmoi diff` before apply.
- Known fragility: store-path rewrite exhaustiveness (6a.2 grep gate); fish alias smoke-test; bootstrap-order guards (6a.3) so fresh machine degrades gracefully.
