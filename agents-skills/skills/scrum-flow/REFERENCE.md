# ClickUp + Discord command reference

Only needed for the interactive workflows (creating or moving tasks). The daily
standup is `post-standup.sh` and needs none of this.

Load config first: see [SKILL.md](SKILL.md).

## Check config

Expect `200`/`200`. `401` = bad token. Discord `404` = webhook deleted.

```bash
curl -s -o /dev/null -w 'clickup:%{http_code}\n' -H "Authorization: $CLICKUP_TOKEN" https://api.clickup.com/api/v2/user
curl -s -o /dev/null -w 'discord:%{http_code}\n' "$DISCORD_WEBHOOK_URL"
```

## Valid status names

Statuses are per-list. Use these strings verbatim; do not guess casing.

```bash
curl -s -H "Authorization: $CLICKUP_TOKEN" \
  "https://api.clickup.com/api/v2/list/$CLICKUP_LIST_ID" | jq -r '.statuses[].status'
```

## Read the board

Sprint lists hold tasks as a *secondary* location, so `GET /list/{id}/task` returns 0
for them. Go via the team endpoint and filter on `.locations`:

```bash
TEAM=$(curl -s -H "Authorization: $CLICKUP_TOKEN" \
  https://api.clickup.com/api/v2/team | jq -r '.teams[0].id')
curl -s -H "Authorization: $CLICKUP_TOKEN" \
  "https://api.clickup.com/api/v2/team/$TEAM/task?include_closed=true&subtasks=true" \
| jq -r --arg L "$CLICKUP_LIST_ID" \
  '.tasks[] | select(.list.id==$L or ((.locations//[])[]?.id==$L))
   | "\(.status.status)\t\(.name)\t\(.id)"'
```

Add `&page=N` and keep going while a page returns 100. `list_ids[]` on this endpoint
does *not* help — it ignores secondary membership too.

## Create a task

```bash
jq -n --arg n "TASK NAME" --arg d "DESCRIPTION" --arg s "to do" \
  '{name:$n, description:$d, status:$s}' \
| curl -s -X POST -H "Authorization: $CLICKUP_TOKEN" -H "Content-Type: application/json" \
  -d @- "https://api.clickup.com/api/v2/list/$CLICKUP_LIST_ID/task" | jq -r '.id + " " + .url'
```

## Move a task

```bash
curl -s -X PUT -H "Authorization: $CLICKUP_TOKEN" -H "Content-Type: application/json" \
  -d '{"status":"in progress"}' \
  "https://api.clickup.com/api/v2/task/TASK_ID" | jq -r '.status.status'
```

## Post to Discord

`jq -n` builds the JSON so newlines and quotes escape correctly — never hand-write the body.

```bash
jq -n --arg c "$MSG" --arg u "$SCRUM_NAME" --arg a "$SCRUM_AVATAR" \
  '{content:$c, username:$u, avatar_url:$a}' \
| curl -s -X POST -H "Content-Type: application/json" -d @- \
  -w '%{http_code}\n' "$DISCORD_WEBHOOK_URL"
```

`204` = posted. `content` caps at 2000 chars — if the draft is longer, trim the draft,
don't split into two posts.

## Stage-timestamp custom fields

This board stamps each column transition into a `date` custom field, which is what the
standup groups on:

| Field | Meaning |
|---|---|
| `In progress at` | entered Do |
| `Ready to test at`, `In test at`, `Ready to review at` | forward progress |
| `In staging at`, `Ready for production at`, `In production at`, `Done at` | forward progress |
| `Blocked since` | blocked, drives Obstacle |
| `Blocked reason` | `labels` field; IDs need a `type_config` lookup to render |

List them with:

```bash
curl -s -H "Authorization: $CLICKUP_TOKEN" \
  "https://api.clickup.com/api/v2/list/$CLICKUP_LIST_ID/field" \
| jq -r '.fields[] | "\(.type)\t\(.name)"'
```
