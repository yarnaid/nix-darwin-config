{ ... }:
{
  # Reduce unified-logging chattiness on subsystems that flood Persist
  # without forensic value. Identified May 2026 via `log show` sampling
  # (~600-800 msg/sec; /var/db/diagnostics had grown to 2.5G).
  #
  # Subsystems we silence:
  #   com.apple.runningboard          - process lifecycle spam
  #   com.apple.WebKit                - per-page chatter from Safari/Raycast
  #   com.apple.duetactivityscheduler - background scheduling churn
  #   com.apple.CMContinuityCapture   - iPhone-as-camera bridge
  #   com.apple.network               - low-level network events
  #   com.apple.CFNetwork             - per-request CFNet logs
  #   com.apple.xpc                   - inter-process plumbing
  #
  # NOT touched on purpose:
  #   com.sentinelone.agent - MDM-managed (Persist:Info, Privacy:Public).
  #     Change only via corp IT; local edits get overwritten by profile.
  #
  # `default` mode = only default/error/fault levels; Info/Debug are
  # captured in memory only and not persisted to disk.
  system.activationScripts.tameUnifiedLog.text = ''
    for sub in \
      com.apple.runningboard \
      com.apple.WebKit \
      com.apple.duetactivityscheduler \
      com.apple.CMContinuityCapture \
      com.apple.network \
      com.apple.CFNetwork \
      com.apple.xpc; do
      /usr/bin/log config --subsystem "$sub" --mode 'level:default,persist:default' >/dev/null 2>&1 || true
    done

    # Drop empty diagnosticd filter override left over from a prior MDM payload
    # (0-byte plist; makes diagnosticd burn CPU trying to parse it).
    /bin/rm -f /Library/Preferences/Logging/com.apple.diagnosticd.filter.0LVLL39g 2>/dev/null || true
  '';
}
