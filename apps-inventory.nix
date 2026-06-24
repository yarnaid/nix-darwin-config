{ pkgs, lib, ... }:
# Regenerates INSTALLED-APPS.md on every `darwin-rebuild switch`.
# Runs as user `yarnaid` (brew refuses root, mas needs the user session, the
# repo file is user-owned). Best-effort: never fails activation. Built from
# `ls /Applications` + `brew` + `mas` only — no `system_profiler` (slow);
# /Applications already holds every third-party + MAS GUI app, since macOS
# system apps live under /System/Applications.
let
  user = "yarnaid";
  repo = "/private/etc/nix-darwin";

  generate = pkgs.writeShellScript "inventory-apps" ''
    set -u
    export PATH=/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
    out="${repo}/INSTALLED-APPS.md"
    tmp="$out.tmp.$$"
    brew=/opt/homebrew/bin/brew
    mas=/opt/homebrew/bin/mas

    mas_list()     { [ -x "$mas" ]  && "$mas" list 2>/dev/null | sort -k2 || true; }
    cask_list()    { [ -x "$brew" ] && "$brew" list --cask 2>/dev/null | sort || true; }
    formula_list() { [ -x "$brew" ] && "$brew" list --formula 2>/dev/null | sort || true; }
    apps_list()    { /bin/ls -1d /Applications/*.app 2>/dev/null | sed 's#.*/##; s#\.app$##' | sort; }
    n() { grep -c . 2>/dev/null || echo 0; }

    {
      echo "# Installed applications — inventory snapshot"
      echo
      echo "_Auto-generated on each \`darwin-rebuild switch\` ($(date '+%Y-%m-%d %H:%M %Z') on $(scutil --get LocalHostName 2>/dev/null || hostname -s)). Do not edit by hand — see apps-inventory.nix._"
      echo
      echo "> **Removal safety:** \`homebrew.onActivation.cleanup = \"zap\"\` only uninstalls **Homebrew** casks/formulae/taps not declared in \`brew.nix\`. It runs \`brew bundle cleanup\`, which **never** calls \`mas uninstall\` and never touches non-Homebrew \`.app\` bundles. MAS apps and manually-downloaded apps are not at risk — only undeclared *brew* packages are."
      echo
      echo "## Mac App Store ($(mas_list | n))"
      echo
      echo "Installed via MAS. Not removed by \`zap\`. (id 0 = ad-hoc/non-store bundle.)"
      echo '```'
      mas_list
      echo '```'
      echo
      echo "## Homebrew casks ($(cask_list | n))"
      echo
      echo "GUI apps managed declaratively in \`brew.nix\`."
      echo '```'
      cask_list
      echo '```'
      echo
      echo "## Homebrew formulae / CLI ($(formula_list | n))"
      echo
      echo '```'
      formula_list
      echo '```'
      echo
      echo "## All /Applications bundles ($(apps_list | n))"
      echo
      echo "Every GUI app present, including manual downloads (GitHub / vendor sites) and other stores (Setapp, Paddle). Cross-reference the MAS and cask lists above to see what is managed; the remainder is installed by hand."
      echo '```'
      apps_list
      echo '```'
    } > "$tmp" && mv -f "$tmp" "$out"
  '';
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    uid=$(/usr/bin/id -u ${user})
    /bin/launchctl asuser "$uid" /usr/bin/sudo -H -u ${user} ${generate} >/dev/null 2>&1 || true
  '';
}
