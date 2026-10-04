{ lib, ... }:
{
  # Opt out of Apple analytics, Siri and proactive suggestions so their
  # background daemons (SubmitDiagInfo/osanalyticshelper, assistantd/Siri,
  # suggestd, duetexpertd) idle instead of learning and uploading.
  #
  # macOS upgrades re-run Setup Assistant and flip these back on (27.0
  # re-enabled Siri and Mac Analytics) — declaring them here re-asserts them on
  # every switch. Re-check this list after each major upgrade.
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
    # Siri itself (incl. Siri AI). Off → duetexpertd/siriknowledged idle.
    # Takes effect for running Siri processes after logout/login.
    "com.apple.assistant.support"."Assistant Enabled" = false;
    # Apple Advertising → Personalized Ads (recommendations from usage data).
    "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
  };

  # Dock "Show suggested and recent apps" — fed by duetexpertd app prediction.
  system.defaults.dock.show-recents = false;

  # Privacy & Security → Analytics & Improvements: "Share Mac Analytics"
  # (AutoSubmit) + "Share with app developers" (ThirdPartyDataSubmit). The
  # plist lives outside /Library/Preferences and its path has a space, which
  # CustomSystemPreferences doesn't quote — so write it here. `defaults write`
  # as root rewrites the file; restore the stock root:admin 664 so System
  # Settings (running as the user) can still read the toggle state.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    diag="/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist"
    if /usr/bin/defaults write "$diag" AutoSubmit -bool false \
      && /usr/bin/defaults write "$diag" ThirdPartyDataSubmit -bool false; then
      /usr/sbin/chown root:admin "$diag"
      /bin/chmod 664 "$diag"
    else
      echo "[privacy] failed to disable Mac Analytics in $diag" >&2
    fi
  '';
}
