#!/bin/bash
# Pulls the ClickUp board, builds the standup, posts it to Discord. Unattended.
set -euo pipefail

# Anything already exported on the command line wins over the env file, so a test run
# can redirect the webhook or the list without editing ~/.secrets. Without this the
# file would silently clobber the override and post to the real channel.
_ovr_hook=${DISCORD_WEBHOOK_URL:-}; _ovr_list=${CLICKUP_LIST_ID:-}
set -a; . "${SCRUM_ENV:-$HOME/.secrets}"; set +a
DISCORD_WEBHOOK_URL=${_ovr_hook:-${DISCORD_WEBHOOK_URL:-}}
CLICKUP_LIST_ID=${_ovr_list:-${CLICKUP_LIST_ID:-}}
CLICKUP_TOKEN="${CLICKUP_TOKEN:-${CLICKUP_API_KEY:-}}"
: "${CLICKUP_TOKEN:?}" "${CLICKUP_LIST_ID:?}" "${DISCORD_WEBHOOK_URL:?}"

# "Yesterday" = closed since the last successful post, so a skipped day, weekend or
# holiday rolls forward instead of silently dropping that work. First run: last 24h.
STATE="${SCRUM_STATE:-$HOME/.local/state/scrum-flow/last_run}"
mkdir -p "$(dirname "$STATE")"
SINCE_S=$(cat "$STATE" 2>/dev/null || echo $(( $(date +%s) - 86400 )))
SINCE_MS=$(( SINCE_S * 1000 ))

TASKS=$(
  TEAM=$(curl -fsS -H "Authorization: $CLICKUP_TOKEN" \
    https://api.clickup.com/api/v2/team | jq -r '.teams[0].id')
  ME="${SCRUM_ASSIGNEE:-$(curl -fsS -H "Authorization: $CLICKUP_TOKEN" \
    https://api.clickup.com/api/v2/user | jq -r '.user.id')}"

  # Sprint lists usually hold tasks as a *secondary* location (Tasks in Multiple Lists),
  # so GET /list/{id}/task returns nothing. The team endpoint sees them, but its
  # list_ids[] filter ignores secondary membership too — hence filtering on .locations
  # here. Server-side assignee filter keeps the paging short.
  page=0
  while :; do
    r=$(curl -fsS --retry 2 -H "Authorization: $CLICKUP_TOKEN" \
      "https://api.clickup.com/api/v2/team/$TEAM/task?include_closed=true&subtasks=true&assignees%5B%5D=$ME&page=$page")
    jq -c '.tasks[]' <<<"$r"
    [[ $(jq -r '.tasks|length' <<<"$r") -lt 100 ]] && break
    page=$((page+1))
  done | jq -s --arg L "$CLICKUP_LIST_ID" \
    '{tasks: [.[] | select(.list.id==$L or ((.locations//[])[]?.id==$L))]}'
)

# Grouping uses this board's stage-timestamp custom fields, which record when a task
# entered each column — an exact transition record, unlike .date_updated (fires on any
# edit) or status names. Any forward stamp newer than the watermark means "Did".
# "In progress at" is excluded from that set because it marks entering Do, not leaving it.
# ponytail: obstacles list task names only; "Blocked reason" is a labels field whose IDs
# need a second type_config lookup to render — add it if the reason matters in the post.
MSG=$(jq -r --argjson since "$SINCE_MS" '
  def items: if length==0 then "-" else
      ([.[0:15][] | "- " + .name] | join("\n"))
      + (if length > 15 then "\n- (+\(length-15) more)" else "" end)
    end;
  def cf($n): [ .custom_fields[]? | select(.name==$n and (.value//"")!="") ] | length > 0;
  def advanced: [ .custom_fields[]?
      | select(.type=="date" and (.value//"")!="")
      | select((.name|IN("In progress at","Blocked since"))|not)
      | select((.value|tonumber) >= $since) ] | length > 0;
  def blocked: cf("Blocked since");
  def inprog: .status.status | ascii_downcase | test("in progress");
  .tasks as $t
  | { did: [ $t[] | select(advanced and (blocked|not)) ],
      do:  [ $t[] | select(inprog and (blocked|not)) ],
      obs: [ $t[] | select(blocked) ] }
  | "Did:\n\(.did|items)\nDo:\n\(.do|items)\nObstacle:\n\(.obs|items)"
  | .[0:1990]
' <<<"$TASKS")

# Nothing closed and nothing blocked (a quiet weekend/holiday) = don't post
# "Did: -" / "Obstacle: -" to the channel. Skip, leaving the watermark untouched so
# the next real activity still rolls forward. SCRUM_POST_EMPTY=1 forces a post.
if [[ "${SCRUM_POST_EMPTY:-}" != "1" ]]; then
  QUIET=$(jq -r --argjson since "$SINCE_MS" '
    def cf($n): [ .custom_fields[]? | select(.name==$n and (.value//"")!="") ] | length > 0;
    def advanced: [ .custom_fields[]?
        | select(.type=="date" and (.value//"")!="")
        | select((.name|IN("In progress at","Blocked since"))|not)
        | select((.value|tonumber) >= $since) ] | length > 0;
    def blocked: cf("Blocked since");
    [ .tasks[] | select((advanced and (blocked|not)) or blocked) ] | length == 0
  ' <<<"$TASKS")
  if [[ "$QUIET" == "true" ]]; then echo "nothing to report, skipping"; exit 0; fi
fi

CODE=$(jq -n --arg c "$MSG" --arg u "${SCRUM_NAME:-Daily Scrum}" --arg a "${SCRUM_AVATAR:-}" \
  '{content:$c, username:$u} + (if $a == "" then {} else {avatar_url:$a} end)' \
| curl -fsS -X POST -H "Content-Type: application/json" -d @- \
  -o /dev/null -w '%{http_code}' "$DISCORD_WEBHOOK_URL")

# Only advance the watermark on a confirmed post, so a failed run reposts that work
# tomorrow rather than losing it.
[[ "$CODE" == "204" ]] || { echo "discord returned $CODE" >&2; exit 1; }
date +%s > "$STATE"
echo "posted $(date '+%F %T')"
