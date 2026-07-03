#!/usr/bin/env bash
# Each task does a bulk env read: getEnvs({ prefix: "" }, { tracked }).
# Run 3 sets ONE unrelated ambient variable (DUMMY_CI_RUN_ID), mimicking a
# per-run CI variable such as ACTIONS_ORCHESTRATION_ID.
#
# Expected: an unrelated variable should not affect a build that does not use
#           it. Actual: the tracked query MISSES; the untracked query HITS.
set -euo pipefail
VP=./node_modules/.bin/vp

status() {
  python3 - <<'PY'
import json, glob
d = json.load(open(sorted(glob.glob("node_modules/.vite/task-cache/v*/last-summary.json"))[-1]))
for t in d["tasks"]:
    r = t["result"]; s = json.dumps(r)
    if "CacheHit" in s[:40]:
        print(f"    {t['task_name']}: HIT")
    else:
        i = s.find("cache_status")
        print(f"    {t['task_name']}: MISS {s[i+15:i+95]}")
PY
}

run_case() {
  local task="$1"
  echo "### $task"
  rm -rf node_modules/.vite/task-cache
  "$VP" run "$task" >/dev/null 2>&1;                 echo "  run 1 (cold):";                       status
  "$VP" run "$task" >/dev/null 2>&1;                 echo "  run 2 (unchanged, expect HIT):";       status
  DUMMY_CI_RUN_ID=abc "$VP" run "$task" >/dev/null 2>&1; echo "  run 3 (one unrelated ambient var, expect HIT):"; status
  echo
}

run_case tracked-bulk-env      # getEnvs({prefix:""}, {tracked: true})  -> run 3 MISS (bug)
run_case untracked-bulk-env    # getEnvs({prefix:""}, {tracked: false}) -> run 3 HIT  (control)
