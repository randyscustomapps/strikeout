#!/usr/bin/env bash
# Point the Play app at another origin. Does not change the public store page.
# Usage: play/set-app-origin.sh new-host.example
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ $# -ne 1 ]]; then
  echo "Usage: play/set-app-origin.sh new-host.example" >&2
  exit 1
fi

new="$1"
new="${new#https://}"
new="${new%/}"
if [[ "$new" == */* || -z "$new" ]]; then
  echo "Give a hostname only, with no path." >&2
  exit 1
fi

old="$(tr -d '[:space:]' < play/app-origin.txt)"
if [[ "$old" == "$new" ]]; then
  echo "Already $new"
  exit 0
fi

python3 - "$old" "$new" << 'PY'
import pathlib, sys
old, new = sys.argv[1], sys.argv[2]
files = [
    "play/android/twa-manifest.json",
    "play/android/app/build.gradle",
    "play/android/app/src/main/res/values/strings.xml",
    "play/android/app/src/main/res/raw/web_app_manifest.json",
    "play/README.md",
]
for name in files:
    path = pathlib.Path(name)
    if not path.exists():
        continue
    text = path.read_text()
    if old not in text:
        continue
    path.write_text(text.replace(old, new))
pathlib.Path("play/app-origin.txt").write_text(new + "\n")
print(new)
PY
