#!/bin/bash
# Lists the sprint lists in the ClickUp sprint folder as "<list_id>  <name>", so you can
# grab the current sprint's id and set CLICKUP_LIST_ID in ~/.secrets when it rolls over.
set -euo pipefail
set -a; . "${SCRUM_ENV:-$HOME/.secrets}"; set +a
: "${CLICKUP_API_KEY:?}" "${CLICKUP_SPRINT_FOLDER_ID:?}"
curl -fsS -H "Authorization: $CLICKUP_API_KEY" \
  "https://api.clickup.com/api/v2/folder/$CLICKUP_SPRINT_FOLDER_ID/list" \
  | jq -r '.lists[] | "\(.id)  \(.name)\(if .id==env.CLICKUP_LIST_ID then "  <- current" else "" end)"'
