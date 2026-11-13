# Strikeout Harvest iPhone project

Offline iPhone app. Bundle id `com.randyscustomapps.strikeout`. Display name Strikeout Harvest. Version 1.0.81, build 1. iPhone only. Portrait, landscape left, and landscape right. Deployment target iOS 16.

The enrollment, the Paid Apps agreement, the subscription, and the listing are in `appstore/README.md`. This file is the project, the local StoreKit test, the signing secrets, and the TestFlight upload.

The calculator is the web app, copied into the bundle at build time. The copy is not committed. `ios/scripts/sync-web.sh` reads the repo root and writes `ios/Strikeout/Web/`. It does not modify `index.html`, `privacy.html`, `sw.js`, or `version.json`. The Xcode build runs that script first. The bundled privacy page is `appstore/privacy.html`, with the font paths adjusted for the bundle.

The pages load from `strikeout://app/index.html`, not from the internet. That address is the saved-data origin. Do not rename the scheme or the host `app`, or every iPhone loses its field setup. The storage key inside the page is still `strikeout.v1`. The subscription cache is a different key, `strikeout.ios.entitlement`, in the app's own defaults. It stores the product id and the expiration. It is not the field setup, and it is not uploaded.

What the shell adds, and the website does not:

- StoreKit 2 subscription `com.randyscustomapps.strikeout.yearly`. One year, $24.99 CAD, 3-day free trial for a new subscriber. The paywall shows the price, the length, the trial, that it renews until cancelled, Restore Purchases, Manage subscription, and links to the Privacy Policy and Terms of Use.
- A verified subscription keeps working with no signal until it expires. A phone that has never subscribed stays on the trial screen until it can reach the App Store.
- System share sheet for Send to Android phone (a link to the public site) and Send to iPhone (`strikeout-headers.json`).
- System document picker for Import header file, plus opening a header JSON from another app.
- Keep screen on, through the system idle timer.
- Light haptics on buttons, and a success haptic when a purchase goes through.
- Status bar, safe area, and light or dark chrome that follow the app's Day and Night. The page uses the safe area, so the Dynamic Island, the notch, and the home indicator do not cover the buttons. Portrait and landscape.
- Dynamic Type scales the notes and the paywall disclosure. The big field buttons stay the size they are.
- No service worker and no version.json fetch. Updates are App Store updates. The Check for updates button is hidden. The web-app manifest link is removed, so the shell does not offer Add to Home Screen.
- http and https pages are not loaded in the app. A tap on the Privacy Policy stays inside the bundle. A tap on Apple's standard Terms opens Safari. mailto opens Mail. This is not a browser.

Location is When In Use only, for Auto line advance and for Screen set to Auto. The app does not use location when Auto is off and Screen is Day or Night. Motion permission is denied. The page uses GPS heading and does not ask for the compass dialog.

iPhone only, on purpose. The column is a cab phone. An iPad layout and 13-inch screenshots are a different piece of work. `TARGETED_DEVICE_FAMILY` is 1.

## Try the subscription on a simulator

You need Xcode for this part. The GitHub check does not run the app.

1. Open `ios/Strikeout.xcodeproj`.
2. Scheme Strikeout, any iPhone simulator. The scheme points at `ios/Strikeout/Strikeout.storekit`. That file is the Canada storefront, product `com.randyscustomapps.strikeout.yearly`, one year, 3-day free trial. It is not in the app that ships.
3. Run. The first screen is the trial. Tap Start free trial. Xcode's StoreKit sheet confirms it. No charge.
4. Stop the app, turn the simulator's network off, and run again. The calculator should open, because the entitlement was verified.
5. Editor → StoreKit → Delete the transaction, run again. The trial screen should be back.

## Unsigned build

No secrets. The project sets `CODE_SIGNING_ALLOWED` to NO so a machine without a team can still compile for the simulator.

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

## Signing secrets

`.github/workflows/ios-appstore.yml` is manual. It is not part of the unsigned check. When you run it, it builds an IPA and uploads that IPA to TestFlight. It does not submit the app for review.

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

The API key is what the upload step uses. Create the app record in App Store Connect before the first upload, or Apple rejects the file. Create the subscription before you test a purchase in TestFlight. The product id has to be `com.randyscustomapps.strikeout.yearly`.

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

App Store Connect → Users and Access → Integrations → App Store Connect API → Team Keys. Access: Admin or App Manager. Download the `.p8` once. Key id and issuer id are on that page. The key contents are `APPSTORE_API_KEY_P8`.

## Upload to TestFlight

GitHub → Actions → **iOS App Store** → Run workflow. It runs only when you start it. It uploads to TestFlight and keeps the IPA as a workflow artifact. It does not press Submit for Review.

On your iPhone, install the build from TestFlight. Settings → App Store → Sandbox Account, with a sandbox tester you created under Users and Access. Open the app. Confirm the sheet says 3 days free, then $24.99 CAD a year, before anyone pays.

## Icons

`ios/scripts/make-icons.py` rebuilds the asset catalog and `appstore/icon-1024.png` from `play/graphics/icon-512.png`. It does not edit the Play file. The marketing icon is RGB, no alpha. The launch image is a separate rounded mark on `#F2DFA7` and is allowed to have transparent corners.

## Screenshots

`appstore/scripts/capture.mjs` reshoots the store images from the bundled page, after `sync-web.sh`. It needs Puppeteer Core and Chrome. The committed PNGs are the ones to upload. Sizes are in `appstore/listing.md`.
