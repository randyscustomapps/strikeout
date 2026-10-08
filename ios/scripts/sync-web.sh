#!/bin/bash
# Copy the web app into the iOS bundle and apply the shell hooks.
# Reads the repo root. Does not modify index.html, privacy.html, sw.js, or version.json.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEST="$ROOT/ios/Strikeout/Web"
SRC_INDEX="$ROOT/index.html"

if [[ ! -f "$SRC_INDEX" ]]; then
  echo "sync-web: missing $SRC_INDEX" >&2
  exit 1
fi

rm -rf "$DEST"
mkdir -p "$DEST/fonts"

cp "$SRC_INDEX" "$DEST/index.html"
cp "$ROOT/privacy.html" "$DEST/privacy.html"
cp "$ROOT/ios/web-shell/native.js" "$DEST/native.js"
cp "$ROOT/icon-192.png" "$ROOT/icon-512.png" "$ROOT/apple-touch-icon.png" "$DEST/"
cp -R "$ROOT/fonts/." "$DEST/fonts/"

python3 - "$DEST/index.html" << 'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
original = text

def once(old, new, label):
    global text
    n = text.count(old)
    if n != 1:
        raise SystemExit(f"sync-web: expected 1 occurrence of {label}, found {n}. index.html changed; update ios/scripts/sync-web.sh")
    text = text.replace(old, new, 1)

once(
    '<link rel="manifest" href="manifest.webmanifest">\n',
    '',
    'manifest link',
)
once(
    '<script>window.STRIKEOUT_PWA=true;</script>\n',
    '<script>window.STRIKEOUT_PWA=true;</script>\n<script src="native.js"></script>\n',
    'PWA flag script',
)
once(
    '  const u=new URL(location.href);\n',
    "  const u=new URL(window.STRIKEOUT_IOS?'https://randyscustomapps.github.io/strikeout/':location.href);\n",
    'header share origin',
)
once(
    'async function shareHeaderLink(){\n  const url=headerShareUrl();\n  if(navigator.share){\n',
    """async function shareHeaderLink(){
  const url=headerShareUrl();
  if(window.strikeoutNative&&window.strikeoutNative.available){
    try{
      await window.strikeoutNative.shareLink(url);
      setHeadNote('Header link ready to send. The other phone opens it and picks Keep or Replace.');
      return;
    }catch(e){if(e&&e.name==='AbortError')return;}
  }
  if(navigator.share){
""",
    'shareHeaderLink',
)
once(
    """async function shareHeaderFile(){
  const text=JSON.stringify(headerFileObj(),null,2);
  const blob=new Blob([text],{type:'application/json'});
  const file=new File([blob],'strikeout-headers.json',{type:'application/json'});
  if(navigator.share&&navigator.canShare&&navigator.canShare({files:[file]})){
""",
    """async function shareHeaderFile(){
  const text=JSON.stringify(headerFileObj(),null,2);
  if(window.strikeoutNative&&window.strikeoutNative.available){
    try{
      await window.strikeoutNative.shareFile('strikeout-headers.json',text);
      setHeadNote('Header file ready to send. On the other phone, tap Import header file.');
      return;
    }catch(e){if(e&&e.name==='AbortError')return;}
  }
  const blob=new Blob([text],{type:'application/json'});
  const file=new File([blob],'strikeout-headers.json',{type:'application/json'});
  if(navigator.share&&navigator.canShare&&navigator.canShare({files:[file]})){
""",
    'shareHeaderFile',
)
once(
    "$('importHeads').addEventListener('click',()=>$('importFile').click());\n",
    """$('importHeads').addEventListener('click',()=>{
  if(window.strikeoutNative&&window.strikeoutNative.available){
    window.strikeoutNative.pickHeaderFile().then(function(text){
      if(text)window.strikeoutNative.receiveFile(text);
    }).catch(function(e){if(e&&e.name==='AbortError')return;});
    return;
  }
  $('importFile').click();
});
""",
    'import click',
)
once(
    "  const body='\\n\\n\\n---\\nApp version: '+APP_VERSION+'\\nDevice: '+(navigator.userAgent||'')+'\\nRunning: '+(installed?'installed (standalone)':'in the browser');\n",
    "  const body='\\n\\n\\n---\\nApp version: '+APP_VERSION+'\\nDevice: '+(navigator.userAgent||'')+'\\nRunning: '+(window.STRIKEOUT_IOS?'App Store app':(installed?'installed (standalone)':'in the browser'));\n",
    'support mail body',
)

old_help = "If location is denied, Auto turns off and the typed row still works. On iPhone, choose <b>Allow While Using App</b> (not Allow Once) the first time. iPhone forgets a tap on <b>Allow</b> each time Strikeout restarts. To stop it asking, open this site in Safari, tap <b>aA</b> → <b>Website Settings</b> → <b>Location</b> → <b>Allow</b>."
new_help = "If location is denied, Auto turns off and the typed row still works. Choose <b>Allow While Using App</b> the first time iPhone asks. The App Store app remembers that choice. Location stays on this phone and is not uploaded."
once(old_help, new_help, 'Safari location help')

old_file = "Got a file? Save it to Files, then tap Import header file."
new_file = "Tap Import header file and choose the file, or open it from the share sheet in another app."
n = text.count(old_file)
if n < 1:
    raise SystemExit("sync-web: header-file note not found")
text = text.replace(old_file, new_file)

if "sw.js" in text and "serviceWorker.register('sw.js')" not in text:
    pass
if "native.js" not in text:
    raise SystemExit("sync-web: native.js was not inserted")
if text == original:
    raise SystemExit("sync-web: bundle was not patched")
path.write_text(text, encoding="utf-8")
print(f"sync-web: patched bundle ({n} header-file notes)")
PY

# The live site files stay as they were. version.json is not part of the bundle:
# the App Store ships updates, and the web app's update check must not run offline
# against a cached copy.
if [[ -e "$DEST/sw.js" || -e "$DEST/version.json" ]]; then
  echo "sync-web: bundle must not contain sw.js or version.json" >&2
  exit 1
fi

echo "sync-web: $DEST"
