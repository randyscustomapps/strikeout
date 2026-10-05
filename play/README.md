# Strikeout Harvest on Google Play

Draft launch assets for the paid Android app. The website at `https://randyscustomapps.github.io/strikeout/` stays the free demo. Nothing in this folder changes `index.html`, `sw.js`, or `version.json`.

The Android package is a Trusted Web Activity: a thin app that opens that URL in Chrome, fullscreen, once Digital Asset Links check out. Bubblewrap 1.25.0 generated `play/android/` from the live web manifest.

## Package name — change it before the first upload

Suggested application id: **`com.randyscustomapps.strikeout`**

It is only a suggestion. Play locks the id at the first upload, and it cannot be renamed later. If you want a different id, change `packageId` in `play/android/twa-manifest.json`, run `bubblewrap update --skipVersionUpgrade` inside `play/android/`, and use the same id in `play/.well-known/assetlinks.json`. Do that before anyone uploads an AAB.

## What the Android project is

| | |
| --- | --- |
| Start URL | `https://randyscustomapps.github.io/strikeout/` |
| Orientation | Portrait. The website manifest still allows any orientation. The Play app does not. |
| Theme | Status and navigation `#2A1D0A` (day chrome) and `#0C0904` (night). Splash background `#F2DFA7`, from the web manifest. |
| Icon | The live `icon-512.png`: flat-auger combine and the STRIKEOUT / HARVEST lockup. |
| minSdk / targetSdk | 21 / 36. New Play apps in October 2026 have to target Android 16 (API 36). |
| Version | `versionName` 1.0.77, `versionCode` 1, matching the current site. Play's versionCode must go up on every upload. It is independent of the website's `APP_VERSION` after this. |
| Location | Location delegation is on, so GPS uses the Android permission dialog. The manifest requests precise and coarse location, in the foreground. |
| Name | Application name Strikeout Harvest. Launcher label Strikeout, same as the web manifest `short_name`, so it fits under the icon. |
| Notifications | DelegationService stays enabled so location delegation can register. Strikeout Harvest never posts a notification. `build-release.sh` strips `POST_NOTIFICATIONS` after a Bubblewrap update rewrites the manifest. |
| Fallback | Custom Tabs, if the device has no Trusted Web Activity browser. Not a bundled WebView. |
| Offline | The site's service worker. Open the app once with a connection so Chrome can cache it. After that it runs with no cell service, same as the home-screen install. Offline fullscreen mode also needs the asset links file below. Until that file is live, Chrome may show a browser bar, and the cached pages still load. |

Chrome, or another browser that implements Trusted Web Activity, has to be on the phone. The app does not embed the website.

## Upload key — generate it yourself

Do not commit the keystore or the passwords. `play/android/.gitignore` excludes `signing/`.

On a computer you control, with JDK 17 and `@bubblewrap/cli` installed:

```bash
cd play/android
./generate-upload-key.sh
./build-release.sh
```

`generate-upload-key.sh` writes:

- `play/android/signing/upload-keystore.jks` — alias `upload`, RSA 2048, 20000 days, PKCS12
- `play/android/signing/passwords.env` — mode 600, both Bubblewrap variables set to the same password

The script does not print the password. It does print the upload certificate SHA-256. That fingerprint is for sideload tests only.

`build-release.sh` reads `passwords.env` and runs `bubblewrap build`. Outputs, also gitignored:

- `play/android/app-release-bundle.aab` — upload this to Play
- `play/android/app-release-signed.apk` — sideload test

Bubblewrap needs JDK 17 specifically, plus Android SDK 36 and build-tools 36.1.0. Point it at them once:

```bash
bubblewrap updateConfig --jdkPath="/path/to/jdk-17" --androidSdkPath="/path/to/android-sdk"
```

The SDK directory has to contain a `bin` or `tools` folder (the command-line tools). `bubblewrap doctor` checks that.

### Hand the key off

The keystore is the upload key. Lose it and the next update needs a Play upload-key reset. Play App Signing keeps the app signing key, which is a different certificate.

1. Run the script on your own machine. Do not use a keystore a cloud agent generated. That machine goes away, and an AAB signed with a key you do not hold should not be the first upload.
2. Put `upload-keystore.jks` and `passwords.env` in a password manager (file attachment plus the password in a vault item). Keep a second copy offline, on an encrypted drive.
3. Share the vault item with the account owner. Do not email the file, do not paste the password into chat, Slack, GitHub, or this pull request.
4. The Play Console account owner should be able to get both files without asking someone to read a password aloud.

A signed AAB was built on the machine that prepared this branch, to prove the project compiles and the bundle verifies. That AAB and its keystore were not committed. Generate a new key and rebuild before you upload.

## Digital Asset Links

Chrome only treats the app as a Trusted Web Activity after it finds a statement for this package on the **host root**:

`https://randyscustomapps.github.io/.well-known/assetlinks.json`

Not under `/strikeout/`. A file in this repo at `play/.well-known/assetlinks.json` is the template. GitHub Pages for the `strikeout` project serves it at `https://randyscustomapps.github.io/strikeout/play/.well-known/assetlinks.json`, and Chrome will not look there.

The template is a JSON array. `Content-Type` must be `application/json`, over HTTPS, with no login and no redirect to HTML. GitHub Pages does that for a `.json` file.

### Where it has to live

**Option A — user site repo. This matches the current URL.**  
Create a GitHub repo named exactly `randyscustomapps.github.io`, owned by the `randyscustomapps` account. Put the file at `.well-known/assetlinks.json` on the branch Pages serves. That becomes `https://randyscustomapps.github.io/.well-known/assetlinks.json`. The Strikeout site can stay in the `strikeout` repo. Only the asset links file has to be on the user site. The two repos do not share a folder.

**Option B — a domain you control at the root.**  
Point the TWA at that host instead (`host`, `startUrl`, and `fullScopeUrl` in `twa-manifest.json`), rebuild, and serve asset links at `https://that-domain/.well-known/assetlinks.json`. Use this if you do not want a user-site repo. It means a new origin, and phones that already cached `github.io/strikeout/` are a different site.

**What does not work.**  
Serving the file only from the `strikeout` project. `https://randyscustomapps.github.io/strikeout/.well-known/assetlinks.json` is the wrong URL.

### Which SHA-256

After the first upload, Play App Signing is on by default. Phones receive an APK signed by **Google's app signing key**, not by your upload key.

1. Play Console → Test and release → App integrity → App signing.
2. Copy the SHA-256 of the **App signing key certificate**.
3. Put that string in `sha256_cert_fingerprints`, colons included, uppercase hex as Play shows it.
4. If you also want a sideload of your own signed APK to open fullscreen, add the upload certificate SHA-256 from `generate-upload-key.sh` as a second string in the same array. Play installs do not use the upload fingerprint.

If you change the package id, change `package_name` in the same file. Update the file when Play rotates the app signing key (rare; Play shows the new fingerprint).

Check the live file with Google's statement list generator, and in Play Console under the app's deep links / app links, before you expect the browser bar to disappear.

## Purchase check

Recommended for this app: **do not add a license check in the first version.** Sell it as a paid app. Play will not install it for an account that has not paid. The website stays free on purpose, as a demo. There is no account system and no server, and a check that needs either one fights that.

Details, and why Play Billing and the Digital Goods API are the wrong tool for an upfront price:

### Paid app (do this)

In Play Console the app is Paid, one-time, about $24.99 CAD. Google gates the download. Anyone who did not buy it does not get the AAB. Sideloading a copied APK is the hole this leaves open. For a $25 field tool that is an acceptable hole. The pages inside are the same pages as the free site, so a sideload does not unlock private content.

### Play Billing and the Digital Goods API (do not use these for the sticker price)

Play Billing and the Digital Goods API sell in-app products and subscriptions: SKUs the app requests after it is installed. They do not answer "did this user pay the store price?" A paid upfront listing is not an in-app product. Adding a "full version" SKU would be a second way to charge, or a free app with a paywall, which is a different product than the one described here. The web app would also need Play Billing wired through the TWA, and this project does not enable that feature.

### If you later want to refuse a sideload

Two mechanisms exist. Neither is required to ship.

- **Play Integrity API**, `appLicensingVerdict`: `LICENSED`, `UNLICENSED`, or `UNEVALUATED`. This is the current way to ask Play whether the install came from a purchase. The standard API wants a small backend to check the token. Strikeout Harvest has no backend. Skip it until there is one.
- **Licensing Verification Library (LVL)**, the older paid-app check. It can run in the Android wrapper, before the Trusted Web Activity opens, and it talks to Play from the device with the app's license key. It fits a no-server app better than Play Integrity. It is still extra code, obfuscation, and a failure mode in the cab when Play is unreachable. Add it only if copied APKs become a real problem.

Do not block the website. Buyers and demo users load the same origin.

## Store listing and privacy

- Listing copy, content rating, data safety, target age, and the graphic file list: `play/listing.md`
- Privacy policy draft: `play/privacy.html`. Contact email is randyscustomapps@gmail.com. It follows the in-app privacy page and adds the company, the Play purchase, and a contact line.
- Icon, feature graphic, and six phone screenshots: `play/graphics/`

## Randy's checklist in Play Console

The developer account does not exist yet. Nothing here was uploaded.

1. Create an **organization** Play Console account for Randy's Canadian Ltd, not a personal account. Organization accounts need a D-U-N-S number for the company. Account type cannot be switched after verification. The one-time Play registration fee is separate from the app price.
2. Confirm the account shows you can publish to production. Google's 12-tester, 14-day closed test is written for personal accounts created after 13 November 2023. The help page does not put organization accounts under that rule. Look at your own console after verification rather than assuming the button is there.
3. Payments profile and tax for the Canadian company. Set the app to Paid, about **$24.99 CAD**, no in-app products. The website is not part of that price.
4. Create the app. Decide the package id first (`com.randyscustomapps.strikeout` unless you change it). You cannot change it later.
5. On your machine, run `generate-upload-key.sh`, back up the keystore and `passwords.env` in a password manager, then `build-release.sh`. Upload **that** AAB. Leave Play App Signing on.
6. Copy the **App signing** SHA-256 into asset links and publish the file at `https://randyscustomapps.github.io/.well-known/assetlinks.json` from a `randyscustomapps.github.io` repo (option A above).
7. Store listing from `play/listing.md`. Category Tools. Upload the icon, feature graphic, and screenshots in `play/graphics/`.
8. Privacy policy URL: the hosted `play/privacy.html`. Contact email on that page is randyscustomapps@gmail.com.
9. App content: content rating (Everyone-level, not a game), target audience 18 and over only, not designed for children, ads No, data safety No collection, location permission foreground and optional, not background.
10. Ship to an internal test track first and open the app on a phone with Chrome. Confirm the browser bar is gone after asset links propagate, then promote the release.
