#!/usr/bin/env bash
# Build a signed release AAB and APK with the local upload key.
# Requires JDK 17, the Android SDK, and @bubblewrap/cli on PATH.
# Bubblewrap reads BUBBLEWRAP_KEYSTORE_PASSWORD and BUBBLEWRAP_KEY_PASSWORD.
set -euo pipefail
cd "$(dirname "$0")"

if [[ ! -f signing/upload-keystore.jks || ! -f signing/passwords.env ]]; then
  echo "No upload key yet. Run ./generate-upload-key.sh on a machine you control." >&2
  exit 1
fi
if ! command -v bubblewrap >/dev/null 2>&1; then
  echo "bubblewrap is not on PATH. Install it with: npm install -g @bubblewrap/cli" >&2
  exit 1
fi

# bubblewrap update rewrites AndroidManifest.xml and, when notification delegation
# is on, inserts POST_NOTIFICATIONS. Location delegation needs that service enabled,
# but Strikeout Harvest never posts a notification. Strip the permission before compiling.
python3 - << 'PY'
from pathlib import Path
import re
p = Path("app/src/main/AndroidManifest.xml")
text = p.read_text()
text = text.replace(
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n    package="com.randyscustomapps.strikeout">',
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n    xmlns:tools="http://schemas.android.com/tools"\n    package="com.randyscustomapps.strikeout">',
)
text = re.sub(
    r'\n[ \t]*<uses-permission android:name="android\.permission\.POST_NOTIFICATIONS"\s*/>\n',
    '\n',
    text,
)
needle = '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" tools:node="remove" />'
if needle not in text:
    text = text.replace(
        'package="com.randyscustomapps.strikeout">',
        'package="com.randyscustomapps.strikeout">\n\n    ' + needle,
        1,
    )
if 'xmlns:tools=' not in text:
    raise SystemExit('AndroidManifest.xml is missing the tools namespace; patch it by hand.')
p.write_text(text)
PY

set -a
# shellcheck disable=SC1091
source signing/passwords.env
set +a

if [[ -z "${BUBBLEWRAP_KEYSTORE_PASSWORD:-}" || -z "${BUBBLEWRAP_KEY_PASSWORD:-}" ]]; then
  echo "signing/passwords.env is missing BUBBLEWRAP_KEYSTORE_PASSWORD or BUBBLEWRAP_KEY_PASSWORD." >&2
  exit 1
fi

bubblewrap build --skipPwaValidation

echo
echo "Signed App Bundle: $(pwd)/app-release-bundle.aab"
echo "Signed APK (sideload test): $(pwd)/app-release-signed.apk"
echo "Both are gitignored. Upload the AAB in Play Console. Keep the keystore."
