#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title open project
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.description open iterm 2x2 layout in a project folder
# @raycast.argument1 { "type": "dropdown", "placeholder": "project", "data": [] }

# Documentation:
# @raycast.author iaroslav_naiden
# @raycast.authorURL https://raycast.com/iaroslav_naiden

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
osascript "$SCRIPT_DIR/open-project.applescript" "$1"
