#!/usr/bin/env python3
"""Post a merge request review notification to Discord.

Secrets come from ~/.secrets (sourced with bash) and are never printed.
Exit codes: 0 posted / dry run / check ok, 1 bad input,
            2 Discord error, 3 setup missing (~/.secrets or required keys).
"""
import argparse
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

KEYS = ("DISCORD_MERGE_REQUEST_WEBHOOK", "REVIEWER_DISCORD_USER_ID", "MERGE_REQUEST_BY")
SECRETS = os.path.expanduser("~/.secrets")
WEBHOOK_RE = re.compile(r"^https://(?:\w+\.)?discord(?:app)?\.com/api/webhooks/\d+/[\w-]+$")
SNOWFLAKE_RE = re.compile(r"^\d{15,21}$")

SETUP_HELP = f"""Setup needed. Create {SECRETS} (chmod 600) containing:

  export DISCORD_MERGE_REQUEST_WEBHOOK="https://discord.com/api/webhooks/<id>/<token>"
  export REVIEWER_DISCORD_USER_ID="<default reviewer's Discord user id>"
  export MERGE_REQUEST_BY="<your name as shown in the notification>"

Webhook: Discord channel > Edit Channel > Integrations > Webhooks > New Webhook > Copy URL.
User id: Discord Settings > Advanced > Developer Mode on, then right-click the user > Copy User ID.
REVIEWER_DISCORD_USER_ID is optional if you always pass --reviewer;
MERGE_REQUEST_BY is optional if you always pass --by."""


def load_secrets() -> tuple[dict, bool]:
    env = {k: os.environ.get(k, "") for k in KEYS}
    exists = os.path.isfile(SECRETS)
    if exists:
        script = 'source "$1" >/dev/null 2>&1; for k in ' + " ".join(KEYS) + '; do printf "%s\\0%s\\0" "$k" "${!k}"; done'
        out = subprocess.run(["bash", "-c", script, "_", SECRETS], capture_output=True, check=False).stdout
        parts = out.decode(errors="replace").split("\0")
        for k, v in zip(parts[0::2], parts[1::2]):
            if v and not env.get(k):
                env[k] = v.strip()
    return env, exists


def setup_problems(s: dict, exists: bool, reviewer: str, by: str) -> list[str]:
    problems = []
    if not exists and not s["DISCORD_MERGE_REQUEST_WEBHOOK"]:
        return [f"{SECRETS} does not exist"]
    if not s["DISCORD_MERGE_REQUEST_WEBHOOK"]:
        problems.append("DISCORD_MERGE_REQUEST_WEBHOOK is not set")
    elif not WEBHOOK_RE.match(s["DISCORD_MERGE_REQUEST_WEBHOOK"]):
        problems.append("DISCORD_MERGE_REQUEST_WEBHOOK is not a Discord webhook URL")
    if not reviewer:
        problems.append("no reviewer: set REVIEWER_DISCORD_USER_ID or pass --reviewer")
    if not by:
        problems.append("no author name: set MERGE_REQUEST_BY or pass --by")
    return problems


def clip(text: str, limit: int) -> str:
    return text if len(text) <= limit else text[: limit - 1] + "…"


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--check", action="store_true", help="Only verify ~/.secrets setup, then exit")
    p.add_argument("--project", help="Project name (ask the user every time)")
    p.add_argument("--title")
    p.add_argument("--url")
    p.add_argument("--ref", default="", help='MR/PR reference, e.g. "!40" or "#12"')
    p.add_argument("--source", default="")
    p.add_argument("--target", default="")
    p.add_argument("--summary", default="")
    p.add_argument("--task-url", default="")
    p.add_argument("--reviewer", default="", help="Discord user id; defaults to REVIEWER_DISCORD_USER_ID")
    p.add_argument("--by", default="", help="Author name; defaults to MERGE_REQUEST_BY")
    p.add_argument("--dry-run", action="store_true", help="Print the payload; do not post")
    a = p.parse_args()

    s, exists = load_secrets()
    reviewer = (a.reviewer or s["REVIEWER_DISCORD_USER_ID"]).strip().strip("<@!>")
    by = (a.by or s["MERGE_REQUEST_BY"]).strip()

    problems = setup_problems(s, exists, reviewer, by)
    if problems:
        print("setup error: " + "; ".join(problems), file=sys.stderr)
        print(SETUP_HELP, file=sys.stderr)
        return 3
    if not SNOWFLAKE_RE.match(reviewer):
        print("error: reviewer must be a numeric Discord user id (15-21 digits)", file=sys.stderr)
        return 1
    if a.check:
        src = "--reviewer" if a.reviewer else "REVIEWER_DISCORD_USER_ID"
        print(f"setup ok: webhook set, reviewer from {src}, by={by}")
        return 0

    for name in ("project", "title", "url"):
        if not (getattr(a, name) or "").strip():
            print(f"error: --{name} is required", file=sys.stderr)
            return 1
    if not a.url.startswith(("https://", "http://")):
        print("error: --url must be an http(s) link", file=sys.stderr)
        return 1

    fields = [
        {"name": "Project", "value": clip(a.project, 1024), "inline": True},
        {"name": "By", "value": clip(by, 1024), "inline": True},
        {"name": "Reviewer", "value": f"<@{reviewer}>", "inline": True},
    ]
    if a.source or a.target:
        fields.append({"name": "Branch", "value": f"`{a.source or '?'}` → `{a.target or '?'}`", "inline": False})
    if a.task_url:
        fields.append({"name": "Task", "value": clip(a.task_url, 1024), "inline": False})

    title = f"[{a.project}] " + (f"{a.ref} " if a.ref else "") + a.title
    payload = {
        "content": f"<@{reviewer}> new merge request for **{a.project}** ready for your review",
        "allowed_mentions": {"parse": [], "users": [reviewer]},
        "embeds": [{
            "title": clip(title, 256),
            "url": a.url,
            "description": clip(a.summary, 4096),
            "color": 0xFC6D26,
            "fields": fields,
        }],
    }

    if a.dry_run:
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        print("dry run: webhook not called", file=sys.stderr)
        return 0

    req = urllib.request.Request(
        s["DISCORD_MERGE_REQUEST_WEBHOOK"],
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json", "User-Agent": "mr-discord-notify/1.1"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            print(r.status)
            return 0
    except urllib.error.HTTPError as e:
        print(e.code)
        print(e.read().decode(errors="replace")[:500], file=sys.stderr)
        if e.code in (401, 404):
            print("The webhook was rejected (deleted or wrong URL). Update DISCORD_MERGE_REQUEST_WEBHOOK.", file=sys.stderr)
        return 2
    except urllib.error.URLError as e:
        print(f"error: {e.reason}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
