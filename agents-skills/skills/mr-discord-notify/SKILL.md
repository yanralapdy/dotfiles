---
name: mr-discord-notify
description: Posts a merge request review notification to the team Discord channel, mentioning the reviewer and labelled with the project name. Use after creating or updating a GitLab merge request / GitHub pull request, or when the user says "notify discord", "ping the reviewer", "send MR notification", or "announce this MR".
---

# MR Discord Notify

Announces a merge request in Discord so the reviewer gets pinged. Run it once per MR, after the MR exists.

```bash
S=~/.dotfiles/agents-skills/skills/mr-discord-notify/scripts/notify.py
```

## Setup (secrets)

The script reads `~/.secrets` and never prints it:

| Key | Use | Required |
|---|---|---|
| `DISCORD_MERGE_REQUEST_WEBHOOK` | Discord webhook URL | yes |
| `REVIEWER_DISCORD_USER_ID` | Default reviewer to @mention | unless `--reviewer` is passed |
| `MERGE_REQUEST_BY` | "By" name | unless `--by` is passed |

**Always run `python3 "$S" --check` first.** If it exits `3`, setup is missing: stop, show the user the setup instructions the script printed, and ask them to create `~/.secrets` (or add the missing keys) themselves. Never create `~/.secrets` or write a webhook value into it yourself, and never ask the user to paste the webhook into the chat. Continue only after they confirm and `--check` passes.

## Workflow

1. **Check setup:** `python3 "$S" --check` (see above).
2. **Ask for the project name. Always ask, on every invoke, even if a name was used earlier in the session.** Use the ask-user tool. Build the options from `projects.txt` in this skill folder (skip `#` lines), and put the current repo's matching name first as `(Recommended)`. Free text stays available ("Other"). If the user types a name that isn't in the list, append it to `projects.txt`.
3. **Ask for the reviewer** with the ask-user tool. Make the first option `Default reviewer from ~/.secrets (Recommended)`; "Other" takes a Discord user id. If the user chooses the default, skips the question, or doesn't answer, leave out `--reviewer`, and the script uses `REVIEWER_DISCORD_USER_ID`. If the user named the reviewer earlier in this request, pass it without asking.
4. **Collect MR facts** from the forge, not from memory:
   - GitLab: `glab mr view <iid> -F json` → `title`, `web_url`, `source_branch`, `target_branch`, `iid`
   - GitHub: `gh pr view <n> --json title,url,headRefName,baseRefName,number`
5. **Write the summary.** 1–3 plain sentences on what changed and why. Add a `⚠️` line for deploy risks (edited migrations, env changes, breaking API) when there are any. If the MR or a commit references a ClickUp/Jira task, pass its URL with `--task-url`.
6. **Dry run, then post:**

```bash
python3 "$S" --project "Prosper" --ref "!40" \
  --title "fix(dncn): map additional discount to add_disc" \
  --url "https://gitlab.example.com/group/repo/-/merge_requests/40" \
  --source fix/dncn-add-disc --target staging \
  --summary "Additional Discount now lands in add_disc…" \
  --task-url "https://app.clickup.com/t/abc123" \
  [--reviewer 123456789012345678] --dry-run
# looks right → same command without --dry-run
```

7. **Report** to the user: the project name, the MR reference, and which reviewer was mentioned (the default or an override).

## Exit codes

| Code | Meaning | Action |
|---|---|---|
| 0 | Posted (prints `204`), dry run, or check ok | — |
| 1 | Bad input (missing `--title`/`--url`/`--project`, or a non-numeric reviewer id) | Fix the arguments |
| 2 | Discord rejected the post or couldn't be reached | Show the error and stop. Don't retry blindly; a retry can post twice. On 401/404 the webhook is dead: ask the user to update it |
| 3 | `~/.secrets` or a required key is missing | Follow Setup above |

## Rules

- Post once per MR. If the user asks again for the same MR, confirm first, since a second post pings the reviewer again.
- Only post after the MR exists and its link opens.
- Only the chosen reviewer is mentioned. `allowed_mentions` is locked to that id, so `@everyone` in a title can't fire.
