# Strikeout Harvest iOS project

Offline iPhone app. Bundle id `com.randyscustomapps.strikeout`. Display name Strikeout Harvest. Version 1.0.77, build 1. iPhone only. Portrait, landscape left, landscape right. Deployment target iOS 16.

The calculator is the web app, copied into the bundle at build time. The copy is not committed. `ios/scripts/sync-web.sh` reads the repo root and writes `ios/Strikeout/Web/`. It does not modify `index.html`, `privacy.html`, `sw.js`, or `version.json`. The Xcode build runs that script first.

The pages load from `strikeout://app/index.html`, not from the internet. That address is the saved-data origin. Do not rename the scheme or the host `app`, or every iPhone loses its field setup. The storage key inside the page is still `strikeout.v1`.

What the shell adds, and the website does not:

- System share sheet for Send to Android phone (a link to the public demo) and Send to iPhone (`strikeout-headers.json`).
- System document picker for Import header file, plus opening a header JSON from another app.
- Keep screen on, through the system idle timer. The page's wake lock is not available in this view.
- Light haptics on buttons, and the page's existing vibrate call.
- Status bar and safe area. Day and night follow the page's theme color.
- No service worker and no version.json fetch. Updates are App Store updates. The Check for updates button is hidden. The web-app manifest link is removed so the shell does not offer Add to Home Screen.
- http and https navigation is cancelled. mailto and tel open the system apps. This is not a browser.

Location is When In Use only, for Auto and for Screen set to Auto. Motion permission is denied. The page uses GPS heading and does not ask for the compass dialog.

## Unsigned build

No secrets. The project sets `CODE_SIGNING_ALLOWED` to NO so a laptop without a team can still compile for the simulator.

```bash
bash ios/scripts/sync-web.sh
xcodebuild \
  -project ios/Strikeout.xcodeproj \
  -scheme Strikeout \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

GitHub Actions runs that, and the same build for a generic iOS device, in `.github/workflows/ios-unsigned.yml`.

## Signing secrets, later

`.github/workflows/ios-appstore.yml` is manual. It is not part of the unsigned check. It builds an IPA and uploads the IPA as a workflow artifact. It does not send the IPA to App Store Connect.

Add these repository secrets. Empty values are why the manual workflow stops at the first step.

| Secret | What it is |
| --- | --- |
| `APPSTORE_API_KEY_ID` | App Store Connect API key id, 10 characters. |
| `APPSTORE_API_ISSUER_ID` | Issuer id on the same API page. |
| `APPSTORE_API_KEY_P8` | The full contents of the `AuthKey_….p8` file, including the BEGIN and END lines. Apple shows this file once. |
| `APPLE_TEAM_ID` | 10-character team id from Membership. |
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64` | Base64 of the Apple Distribution `.p12`. |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | Password set when the `.p12` was exported. |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of the App Store `.mobileprovision` for `com.randyscustomapps.strikeout`. |

The API key is stored so a later upload command can use it. Do not add an upload step until you mean to send a build.

### Make the certificate without a Mac

Any computer with OpenSSL can make the request. Keep `distribution.key` private. It is the private key. Do not commit it.

```bash
openssl genrsa -out distribution.key 2048
openssl req -new -key distribution.key -out distribution.csr \
  -subj "/CN=Strikeout Harvest Distribution/O=1594818 B.C. LTD."
```

In the browser, developer.apple.com → Certificates → plus → **Apple Distribution** → upload `distribution.csr` → download the `.cer`.

```bash
openssl x509 -inform DER -in distribution.cer -out distribution.pem
openssl pkcs12 -export -inkey distribution.key -in distribution.pem -out distribution.p12
# macOS:
base64 -i distribution.p12 | tr -d '\n'
# Linux:
base64 -w0 distribution.p12
```

The last line is `IOS_DISTRIBUTION_CERTIFICATE_BASE64`. The export password is `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`.

### App id and profile

Certificates, Identifiers & Profiles:

1. Identifiers → App IDs → Explicit → `com.randyscustomapps.strikeout`. No extra capabilities. No push, no associated domains, no iCloud.
2. Profiles → App Store Connect → that app id → the distribution certificate from above. Download the `.mobileprovision`.
3. Base64 of that file is `IOS_PROVISIONING_PROFILE_BASE64`. macOS: `base64 -i Profile.mobileprovision | tr -d '\n'`. Linux: `base64 -w0 Profile.mobileprovision`.

`ios/ExportOptions.plist` is the export template. The workflow fills the team id and the profile name. Do not put real secrets in that file.

### API key

App Store Connect → Users and Access → Integrations → App Store Connect API → Team Keys. Access: Admin or App Manager. Download the `.p8` once. Key id and issuer id are on that page.

## Icons

`ios/scripts/make-icons.py` rebuilds the asset catalog and `appstore/icon-1024.png` from `play/graphics/icon-512.png`. It does not edit the Play file. The marketing icon is RGB, no alpha. The launch image is a separate rounded mark on `#F2DFA7` and is allowed to have transparent corners.

## Screenshots

`appstore/scripts/capture.mjs` reshoots the store images from the bundled page, after `sync-web.sh`. It needs Puppeteer Core and Chrome. The committed PNGs are the ones to upload.
