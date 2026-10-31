#!/usr/bin/env bash
set -euo pipefail
umask 077
: "${RUNNER_TEMP:?}" "${RECIPIENT:?}"
work=$(mktemp -d "$RUNNER_TEMP/window-XXXXXX")
trap 'rm -rf -- "$work" "$RUNNER_TEMP/pack"' EXIT
mkdir "$work/result"
rc=0
(cd "$RUNNER_TEMP/pack" && bash run.sh "$work/result") >"$work/run.log" 2>&1 || rc=$?
# Only the encrypted archive leaves this job. A degraded run retains its diagnostics.
cp "$work/run.log" "$work/result/pack.log"
tar -C "$work/result" -czf - . | age -r "$RECIPIENT" -o "$RUNNER_TEMP/output.age"
printf '%s\n' "$rc" > "$RUNNER_TEMP/pack-status"
