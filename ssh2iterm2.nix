{ ... }:
# ssh2iterm2: continuously sync ~/.ssh/config -> iTerm2 dynamic profiles.
# `ssh2iterm2 watch` (rjeczalik/notify) is long-lived: it watches the ssh
# config dir and regenerates ~/Library/Application Support/iTerm2/
# DynamicProfiles on every change. Runs as a per-USER agent (reads ~/.ssh,
# writes ~/Library) — not a root daemon. Binary comes from the homebrew
# formula `arnested/ssh2iterm2/ssh2iterm2` (see brew.nix).
{
  launchd.user.agents.ssh2iterm2 = {
    serviceConfig = {
      Label = "ssh2iterm2";
      # Guard: brew may not have installed the binary yet on a fresh machine.
      # exec only when present, else exit so KeepAlive throttles (10s) instead
      # of crash-looping at "command not found".
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "exec /opt/homebrew/bin/ssh2iterm2 watch"
      ];
      EnvironmentVariables = {
        # ssh2iterm2 resolves the ssh client via exec.LookPath; ensure /usr/bin
        # (and brew) are on the minimal launchd-agent PATH.
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/ssh2iterm2.stderr";
      StandardOutPath = "/tmp/ssh2iterm2.stdout";
    };
  };
}
