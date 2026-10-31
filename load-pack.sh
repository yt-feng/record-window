#!/usr/bin/env bash
set -euo pipefail
umask 077
: "${RUNNER_TEMP:?}" "${PACK_REPO:?}" "${PACK_IDENTITY:?}"
[[ "$PACK_REPO" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]] || exit 1
tmpdir=$(mktemp -d "$RUNNER_TEMP/key-XXXXXX")
trap 'rm -rf -- "$tmpdir"' EXIT
printf '%s\n' "$PACK_IDENTITY" > "$tmpdir/id"
# Use GitHub's HTTPS-published host keys on the ephemeral hosted runner.
curl -fsS --retry 2 https://api.github.com/meta | jq -er '.ssh_keys[] | "github.com " + .' > "$tmpdir/known_hosts"
export GIT_SSH_COMMAND="ssh -F /dev/null -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$tmpdir/known_hosts -i $tmpdir/id"
if ! git clone -q --depth=1 -- "git@github.com:$PACK_REPO.git" "$RUNNER_TEMP/pack" >"$tmpdir/log" 2>&1; then
  echo 'Collection pack unavailable.' >&2; exit 1
fi
