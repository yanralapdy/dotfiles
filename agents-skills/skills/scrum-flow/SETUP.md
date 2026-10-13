# Setup (one time)

## 1. ClickUp personal token

ClickUp → avatar (bottom left) → **Settings** → **Apps** → **API Token** → Generate.
Starts with `pk_`. Sent as a raw `Authorization` header — no `Bearer` prefix.

## 2. ClickUp list ID

Open the kanban list in the browser. The URL ends in the list ID:

```
https://app.clickup.com/<team>/v/li/901234567890
                                      ^^^^^^^^^^^^ this
```

Or find it by name:

```bash
curl -s -H "Authorization: pk_YOUR_TOKEN" \
  "https://api.clickup.com/api/v2/team" | jq -r '.teams[] | .id + " " + .name'
# then walk: /team/{id}/space -> /space/{id}/folder -> /folder/{id}/list
```

## 3. Discord webhook

Requires **Manage Webhooks** on that channel. If it is a server you're only a member of, ask an
admin to create it and send you the URL — the URL is the credential, treat it like a password.

Channel → **Edit Channel** → **Integrations** → **Webhooks** → **New Webhook** → set name and
avatar → **Copy Webhook URL**.

`SCRUM_NAME` and `SCRUM_AVATAR` override the webhook's defaults per message.

## 4. Fill in the vars

They live in `~/.secrets` (mode 600, outside the dotfiles repo). `CLICKUP_API_KEY`
is already there and is reused as the ClickUp token. Fill the blanks:

```bash
export CLICKUP_LIST_ID=901820844215
export DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/.../...
export SCRUM_NAME=Your Name          # optional
export SCRUM_AVATAR=https://.../you.png   # optional
```

Sprint boards rotate — when the sprint rolls over, edit `CLICKUP_LIST_ID` to the
new list's ID. One line, no code change.

## 5. Verify

Run the config check in SKILL.md. Expect `clickup:200` and `discord:200`.

## 6. Turn on the schedule

Dry-run it once first — this posts to the real channel, so do it when a stray message is harmless:

```bash
~/.dotfiles/agents-skills/skills/scrum-flow/post-standup.sh
```

Then install the daily 10:00 job:

```bash
cp ~/.dotfiles/agents-skills/skills/scrum-flow/local.scrum-flow.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/local.scrum-flow.plist
```

From then on it posts unattended. Nothing to invoke.
