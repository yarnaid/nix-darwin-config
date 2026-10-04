{ lib, ... }:
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
  # `level:default` = only default/error/fault are emitted; Info/Debug are
  # dropped entirely (not even in memory). `persist:default` = only those reach disk.
  #
  # Must be postActivation: custom-named activationScripts are silently dropped.
  # It was defined as `tameUnifiedLog` (May–Oct 2026) and never ran; the settings
  # were live only because they had been applied by hand on 2026-05-23.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    for sub in \
      com.apple.runningboard \
      com.apple.WebKit \
      com.apple.duetactivityscheduler \
      com.apple.CMContinuityCapture \
      com.apple.network \
      com.apple.CFNetwork \
      com.apple.xpc; do
      /usr/bin/log config --subsystem "$sub" --mode 'level:default,persist:default' >/dev/null \
        || echo "[logging] log config failed for $sub" >&2
    done

    # Drop empty diagnosticd filter override left over from a prior MDM payload
    # (0-byte plist; makes diagnosticd burn CPU trying to parse it).
    /bin/rm -f /Library/Preferences/Logging/com.apple.diagnosticd.filter.0LVLL39g 2>/dev/null || true
  '';
}
