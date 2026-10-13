#!/bin/bash
# Checks the Did/Do/Obstacle grouping against mock tasks. No creds, no network.
# The blocked and empty-board branches never occur in live data, so they only get
# exercised here. Run after touching the jq block in post-standup.sh.
set -euo pipefail
cd "$(dirname "$0")"

SINCE_MS=1000000
group() {  # reuse the real jq block rather than a copy that can drift
  SINCE_MS=$SINCE_MS TASKS="$1" bash -c '
    set -a; source /dev/null; set +a
    SINCE_MS='"$SINCE_MS"'
    TASKS='"$(printf '%q' "$1")"'
    '"$(awk '/^MSG=\$\(jq -r/,/^'"'"' <<<"\$TASKS"\)$/' post-standup.sh)"'
    printf "%s" "$MSG"'
}

d() { printf '{"name":"%s","type":"date","value":"%s"}' "$1" "$2"; }
task() { printf '{"name":"%s","status":{"status":"%s","type":"custom"},"custom_fields":[%s]}' "$1" "$2" "$3"; }

TASKS=$(printf '{"tasks":[%s,%s,%s,%s]}' \
  "$(task 'moved to test'    'ready to test' "$(d 'In progress at' 500000),$(d 'Ready to test at' 2000000)")" \
  "$(task 'stale in test'    'ready to test' "$(d 'In progress at' 100000),$(d 'Ready to test at' 200000)")" \
  "$(task 'still going'      'in progress'   "$(d 'In progress at' 900000)")" \
  "$(task 'stuck on infra'   'in progress'   "$(d 'In progress at' 900000),$(d 'Blocked since' 950000)")")

OUT=$(group "$TASKS")
echo "$OUT"; echo "---"

grep -qx 'Did:' <<<"$OUT"
grep -qx -e '- moved to test' <<<"$OUT"        || { echo "FAIL: fresh stamp missing from Did"; exit 1; }
grep -qx -e '- stale in test' <<<"$OUT"        && { echo "FAIL: stamp older than watermark leaked into Did"; exit 1; }
grep -qx -e '- still going' <<<"$OUT"          || { echo "FAIL: in-progress task missing from Do"; exit 1; }
grep -qx -e '- stuck on infra' <<<"$OUT"       || { echo "FAIL: blocked task missing from Obstacle"; exit 1; }
[[ $(grep -c -e '- stuck on infra' <<<"$OUT") == 1 ]] || { echo "FAIL: blocked task also listed under Do"; exit 1; }

EMPTY=$(group '{"tasks":[]}')
[[ "$EMPTY" == $'Did:\n-\nDo:\n-\nObstacle:\n-' ]] || { echo "FAIL: empty board rendered as:"; echo "$EMPTY"; exit 1; }

# Quiet day = nothing Did, nothing blocked, even if tasks sit In progress. The skip in
# post-standup.sh keys off exactly that: both Did and Obstacle empty. Mirror the check
# here against a Do-only board so the skip predicate can't silently drift.
DOONLY=$(group "$(printf '{"tasks":[%s]}' "$(task 'still going' 'in progress' "$(d 'In progress at' 900000)")")")
quiet() { grep -qzE 'Did:\n-\n' <<<"$1$(printf '\n')" && grep -qzE 'Obstacle:\n-' <<<"$1$(printf '\n')"; }
quiet "$DOONLY"  || { echo "FAIL: Do-only board not detected as quiet:"; echo "$DOONLY"; exit 1; }
quiet "$OUT"     && { echo "FAIL: active board wrongly detected as quiet"; exit 1; }

echo "PASS"
