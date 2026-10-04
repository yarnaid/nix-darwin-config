{ lib, ... }:
{
  # Opt out of Apple analytics, Siri and proactive suggestions, removing the
  # work of their background daemons (SubmitDiagInfo/osanalyticshelper,
  # assistantd/Siri, suggestd, duetexpertd).
  #
  # macOS upgrades re-run Setup Assistant and flip these back on (observed
  # 2026-10-04: 27.0 left Assistant Enabled=1, AutoSubmit=true) — declaring
  # them here re-asserts them on every switch. Re-check after each major upgrade.
  #
  # The daemons themselves are SIP-protected on-demand agents: `launchctl
  # bootout` fails (150) and `disable` is recorded but ignored — they respawn on
  # Mach-service demand. Only `csrutil disable` removes them, so neutralise the
  # feature, not the process. See ~/.claude/rules/macos-darwin.md.
  system.defaults.CustomUserPreferences = {
    # Siri / Look Up suggestions (duetexpertd + suggestd output in Spotlight,
    # Look Up, App Library). Removes their WORK; PersonalizationPortrait
    # (on-device app-usage learning) has no SIP-safe off-switch.
    "com.apple.suggestions".SuggestionsAppLibraryEnabled = false;
    "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
    # Siri itself — the observed post-upgrade value, not a speculative key.
    # Running Siri processes pick it up after logout/login.
    "com.apple.assistant.support"."Assistant Enabled" = false;
    # Apple Advertising → Personalized Ads (recommendations from usage data).
    "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
  };

  # Dock "Show suggested and recent apps" — fed by duetexpertd app prediction.
  system.defaults.dock.show-recents = false;

  # Privacy & Security → Analytics & Improvements: "Share Mac Analytics"
  # (AutoSubmit) + "Share with app developers" (ThirdPartyDataSubmit). The
  # plist lives outside /Library/Preferences and its path has a space, which
  # CustomSystemPreferences doesn't quote — so write it here. cfprefsd rewrites
  # the plist 0600 on every write → restore the stock root:admin 664 so System
  # Settings (running as the user) can still read it. A missing CrashReporter
  # dir (fresh machine, before Setup Assistant) would be created 0700 → skip.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    diag="/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist"
    if [ ! -d "''${diag%/*}" ]; then
      echo "[privacy] ''${diag%/*} missing; skipping Mac Analytics opt-out" >&2
    else
      /usr/bin/defaults write "$diag" AutoSubmit -bool false \
        && /usr/bin/defaults write "$diag" ThirdPartyDataSubmit -bool false \
        || echo "[privacy] failed to disable Mac Analytics in $diag" >&2
      if [ -f "$diag" ]; then
        /usr/sbin/chown root:admin "$diag" && /bin/chmod 664 "$diag" \
          || echo "[privacy] failed to restore root:admin 664 on $diag" >&2
      fi
    fi
  '';
}
