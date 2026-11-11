#!/usr/bin/env bash
set -euo pipefail

ROOT=$(git -C "$(dirname -- "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
cd "$ROOT"

BRANCH=$(git branch --show-current)
if [[ -z "$BRANCH" ]]; then
    echo "Error: cannot push from a detached HEAD." >&2
    exit 1
fi

git remote get-url origin >/dev/null

python3 - "$ROOT" <<'PY'
import os
import sys

root = sys.argv[1]
converted = 0
for current, dirs, files in os.walk(root, followlinks=False):
    dirs[:] = [name for name in dirs if name != ".git" and not os.path.islink(os.path.join(current, name))]
    for name in files:
        path = os.path.join(current, name)
        if name.lower().endswith(".html") and not os.path.islink(path):
            with open(path, "rb") as html:
                contents = html.read()
            if b"\r\n" in contents:
                with open(path, "wb") as html:
                    html.write(contents.replace(b"\r\n", b"\n"))
                converted += 1

print(f"Converted CRLF to LF in {converted} HTML file(s).")
PY

git add -A
if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

git commit -m "Update project files" \
    -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
git push origin "$BRANCH"

echo "Pushed to origin/$BRANCH. If this is the Pages source branch, deployment will start automatically."
