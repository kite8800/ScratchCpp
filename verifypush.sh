#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git -C "$(dirname -- "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cd "$ROOT"

PAGE_FILE="docs/ScratchPython.html"
PAGE_URL="https://kite8800.github.io/ScratchCpp/ScratchPython.html"
BRANCH="main"

if [[ "$(git branch --show-current)" != "$BRANCH" ]]; then
    echo "Error: GitHub Pages is published from '$BRANCH'; switch to that branch first." >&2
    exit 1
fi

if ! git diff --quiet HEAD -- "$PAGE_FILE"; then
    echo "Error: $PAGE_FILE has uncommitted changes. Run ./commitpush.sh first." >&2
    exit 1
fi

HEAD_SHA=$(git rev-parse HEAD)
if ! REMOTE_SHA=$(git ls-remote origin "refs/heads/$BRANCH" | awk 'NR == 1 { print $1 }'); then
    echo "Error: could not read origin/$BRANCH." >&2
    exit 1
fi
if [[ "$REMOTE_SHA" != "$HEAD_SHA" ]]; then
    echo "Error: local HEAD ($HEAD_SHA) is not the latest pushed commit on origin/$BRANCH ($REMOTE_SHA)." >&2
    exit 1
fi

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

LOCAL_HASH=$(git hash-object "$PAGE_FILE")
RUN_ID="$(date +%s)-$$"
for attempt in {1..24}; do
    if curl --fail --silent --location --max-time 10 --header 'Cache-Control: no-cache' \
        "${PAGE_URL}?verifypush=${HEAD_SHA}-${RUN_ID}-${attempt}" --output "$TMP_FILE"; then
        REMOTE_HASH=$(git hash-object "$TMP_FILE")
        if [[ "$REMOTE_HASH" == "$LOCAL_HASH" ]]; then
            echo "Verified: $PAGE_URL matches $PAGE_FILE at $HEAD_SHA."
            exit 0
        fi
    fi

    if (( attempt < 24 )); then
        echo "Pages has not published the current file yet (check $attempt/24); retrying in 5 seconds..."
        sleep 5
    fi
done

echo "Error: the published page did not match $PAGE_FILE after 24 checks: $PAGE_URL" >&2
exit 1
