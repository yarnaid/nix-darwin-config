#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title open project
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.description open iterm 2x2 layout in a specific folder
# @raycast.argument1 { "type": "text", "placeholder": "~/projects/..." }

# Documentation:
# @raycast.author iaroslav_naiden
# @raycast.authorURL https://raycast.com/iaroslav_naiden

on run argv
  set workDir to item 1 of argv

  -- экспансия ~
  if workDir starts with "~" then
    set workDir to (POSIX path of (path to home folder)) & text 3 thru -1 of workDir
  end if

  tell application "iTerm2"
    activate

    -- если окон нет — создаём, иначе новый таб в текущем окне
    if (count of windows) is 0 then
      create window with default profile
    else
      tell current window
        create tab with default profile
      end tell
    end if

    tell current tab of current window
      tell current session
        split vertically with default profile
      end tell
      tell first session
        split horizontally with default profile
      end tell
      tell third session
        split horizontally with default profile
      end tell
      repeat with s in sessions
        tell s to write text "cd " & quoted form of workDir
      end repeat
    end tell
  end tell

  return "Opened 2x2 grid in " & workDir
end run
