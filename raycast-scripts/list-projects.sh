#!/bin/bash
# regen-project-dropdown.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="${SCRIPT_DIR}/open-project.sh"

ROOTS=(
  "$HOME/projects"
  "$HOME/projects/adnoc"
)

data=$(find "${ROOTS[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null |
  sort |
  jq -Rn '[inputs | {title: (split("/") | "\(.[-1]) (\(.[-2]))"), value: .}]' |
  jq -c .)

escaped=$(printf '%s' "$data" | /usr/bin/sed -e 's/[&|\\]/\\&/g')

/usr/bin/sed -i '' \
  "s|^# @raycast.argument1 .*|# @raycast.argument1 { \"type\": \"dropdown\", \"placeholder\": \"project\", \"data\": $escaped }|" \
  "$SCRIPT"
