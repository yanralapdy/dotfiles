---
name: scrum-flow
description: Turns a plan into ClickUp kanban tasks, tracks their status, and posts an automated daily scrum report to a Discord channel via webhook on a schedule. Use when user says "daily scrum", "standup", "post my standup", "scrum report", "push this plan to ClickUp", "move task to in progress", or wants a grill-me/planning session carried through to ClickUp and reported to Discord.
---

# Scrum Flow

`plan → ClickUp tasks → work → daily scrum post in Discord`

## Config

Load first, every time:

```bash
set -a; . ~/.secrets; set +a
CLICKUP_TOKEN="${CLICKUP_TOKEN:-$CLICKUP_API_KEY}"
```

Vars: `CLICKUP_TOKEN`, `CLICKUP_LIST_ID`, `DISCORD_WEBHOOK_URL`, `SCRUM_NAME`, `SCRUM_AVATAR`.
File missing or a var empty → read [SETUP.md](SETUP.md), do not guess values.
Never print `CLICKUP_TOKEN` or `DISCORD_WEBHOOK_URL` back to the user.

## Commands

curl recipes for reading the board, creating and moving tasks, and posting to Discord:
see [REFERENCE.md](REFERENCE.md). Read it before any ClickUp write — statuses are
per-list and sprint lists need the team endpoint, not `GET /list/{id}/task`.

## Workflow: plan → tasks

1. Get the plan. Fresh session with no plan yet → run the `grill-me` then `session-planner` skills first.
2. Restate the task list as one line each and get the user's OK before creating anything.
3. Fetch valid statuses, then create tasks one call each.
4. Report back the ClickUp URLs.

## Workflow: daily scrum (automated)

`post-standup.sh` does the whole thing — pull board, group, post. No review step, no agent needed.
It runs itself on a schedule; invoke it directly only to test or to post off-cycle:

```bash
~/.dotfiles/agents-skills/skills/scrum-flow/post-standup.sh
```

Test against a throwaway channel instead of the team one. Env vars set on the command
line beat `~/.secrets`, and `SCRUM_STATE` keeps the real watermark untouched:

```bash
DISCORD_WEBHOOK_URL='<test-webhook>' SCRUM_STATE=/tmp/scrum-test \
  ~/.dotfiles/agents-skills/skills/scrum-flow/post-standup.sh
```

`rm /tmp/scrum-test` between runs, or `Did` comes back empty — the watermark from the
previous test is doing its job. To preview without posting anything at all, stop the
script before the POST:

```bash
awk '/^CODE=\$\(jq -n/{exit} {print}' post-standup.sh > /tmp/dry.sh
echo 'printf "%s\n" "$MSG"' >> /tmp/dry.sh && bash /tmp/dry.sh
```

Posted format — plain text, no headers, empty section renders as a bare `-`:

```
Did:
- Lock an approved DNCN from further edits
Do:
- Update print dncn
Obstacle:
-
```

Grouping uses this board's stage-timestamp custom fields, not status names or `date_updated`:

| Section | Source |
|---|---|
| Did | any forward stage stamp (`Ready to test at`, `In test at`, `Done at`, …) newer than the watermark |
| Do | status name containing "in progress", not blocked |
| Obstacle | `Blocked since` populated |

`In progress at` is excluded from the Did set — it marks entering Do, not leaving it. The
stamps are an exact transition record, so a task edited long after it moved will not
resurface under Did the way a `date_updated` check would.

Sections cap at 15 items, overflow becomes `- (+N more)`. Only tasks assigned to the
token's own user are included.

Run `./test-grouping.sh` after touching the jq block — it covers the blocked and
empty-board branches that live data does not exercise.

"Since the last successful post" is a watermark in `~/.local/state/scrum-flow/last_run`, advanced
only on a confirmed `204`. A failed or skipped day therefore rolls its work into the next post
instead of dropping it — do not replace this with a fixed 24h window.

Schedule (every day 10:00):

```bash
cp ~/.dotfiles/agents-skills/skills/scrum-flow/local.scrum-flow.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/local.scrum-flow.plist
```

Check on it: `cat /tmp/scrum-flow.log /tmp/scrum-flow.err`. Change the time by editing the plist,
then `launchctl unload` and `load` again. Stop it entirely with `launchctl unload`.

## Workflow: process a task

Move status, then say what changed. Batch of moves → confirm the whole list once, not per task.

## Notes

A webhook posts under `SCRUM_NAME`/`SCRUM_AVATAR`, not the user's real Discord account. Automating posts as a personal account needs a self-bot, which is against Discord ToS — do not offer it.
