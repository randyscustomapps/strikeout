#!/usr/bin/env bash
# Create the Play upload keystore on THIS machine. Does not print the passwords.
# The keystore and passwords.env are gitignored. Back them up before the first upload.
set -euo pipefail
cd "$(dirname "$0")"

if [[ -e signing/upload-keystore.jks || -e signing/passwords.env ]]; then
  echo "Refusing to overwrite signing/upload-keystore.jks or signing/passwords.env." >&2
  echo "Move them aside yourself if you really mean to generate a new upload key." >&2
  exit 1
fi

KEYTOOL=""
for candidate in \
  /usr/lib/jvm/java-17-openjdk-amd64/bin/keytool \
  /usr/lib/jvm/java-17-openjdk/bin/keytool \
  "$(command -v keytool || true)"
do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    KEYTOOL="$candidate"
    break
  fi
done
if [[ -z "$KEYTOOL" ]]; then
  echo "keytool not found. Install a JDK (17 is what Bubblewrap expects) and re-run." >&2
  exit 1
fi

mkdir -p signing
chmod 700 signing
umask 077

# 24 url-safe characters. Play and Bubblewrap both require at least 6.
# JDK 17 keytool writes a PKCS12 keystore and uses the store password as the key
# password. Bubblewrap still reads both variables, so they are set to the same value.
KS_PASS="$(openssl rand -base64 36 | tr -dc 'A-Za-z0-9' | head -c 24)"

"$KEYTOOL" -genkeypair \
  -keystore signing/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 20000 \
  -storepass "$KS_PASS" \
  -keypass "$KS_PASS" \
  -dname "CN=Strikeout Upload, OU=Mobile, O=Randy's Canadian Ltd, C=CA"

cat > signing/passwords.env << EOF
# Source this file. Do not commit it. Do not paste it into chat, email, or the pull request.
# Both values match because the keystore is PKCS12.
BUBBLEWRAP_KEYSTORE_PASSWORD=${KS_PASS}
BUBBLEWRAP_KEY_PASSWORD=${KS_PASS}
EOF
chmod 600 signing/passwords.env signing/upload-keystore.jks

echo "Created signing/upload-keystore.jks (alias: upload, RSA 2048, 20000 days)."
echo "Passwords are in signing/passwords.env (mode 600). They were not printed."
echo
echo "SHA-256 of THIS upload certificate."
echo "Use it only for sideload tests. The Play listing needs the App signing key SHA-256 from Play Console."
"$KEYTOOL" -list -v \
  -keystore signing/upload-keystore.jks \
  -alias upload \
  -storepass "$KS_PASS" | awk '/SHA256:/{print}'
