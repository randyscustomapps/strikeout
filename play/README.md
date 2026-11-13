# Strikeout Harvest on Google Play

Draft launch assets for the Android app. The Play app is free to install and sells a yearly subscription through Google Play Billing. The website at `https://randyscustomapps.github.io/strikeout/` stays free, and so does a home-screen install that is not the Play app. The subscription gate lives in `index.html` and runs only inside this Trusted Web Activity.

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
| Version | `versionName` 1.0.80, `versionCode` 1. Nothing has been uploaded, so the first upload is still versionCode 1. After that, versionCode must go up on every upload. It is independent of the website's `APP_VERSION`. |
| Play Billing | On. `features.playBilling` in `twa-manifest.json`. The wrapper uses `com.google.androidbrowserhelper:billing:1.2.0` (Play Billing Library 8.3.0). |
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

## Subscription

The app on Play is **free to install**. The charge is an auto-renewing subscription, not a paid download. A paid download cannot offer a 3-day trial, and Play Billing is how a Trusted Web Activity is allowed to sell a digital subscription.

| | Plug this into Play Console |
| --- | --- |
| Product id | `strikeout_yearly` |
| Base plan id | `yearly` |
| Offer id | `trial3` |
| Price | $24.99 CAD a year, auto-renewing |
| Trial | 3 days, free, on the `yearly` base plan |
| Package id | `com.randyscustomapps.strikeout` |

Those three ids are the only store strings in the web app. They sit in the `PLAY` object near the bottom of `index.html`. The same package id is repeated in the small script just inside `<body>`, so the paywall can show before the rest of the script runs. Change both if you change the package.

The page uses the Digital Goods API (`getDigitalGoodsService('https://play.google.com/billing')`) to read the product and `listPurchases()`, and the Payment Request API with method `https://play.google.com/billing` to start the purchase. The request sends `sku`, `offerId`, and `basePlanId`. Play's own sheet is the price the farmer confirms. The $24.99 line on our screen is the fallback until `getDetails` returns Play's price.

The gate runs only when the page was opened as this Play app. Chrome sets `document.referrer` to `android-app://com.randyscustomapps.strikeout` on that launch. A reload in the same tab keeps a `sessionStorage` flag named `strikeout.playtwa` so the gate can come back after the referrer is gone. That flag is not the settings key `strikeout.v1`, and it is not written for a normal browser tab. The website, an iPhone home-screen icon, and an Android install from Chrome's menu never take this path.

Inside the Play app, with no active subscription, the farmer gets one full-screen page: 3-day free trial, then $24.99 CAD a year, a Subscribe button, and a Restore button. The buttons are tall, flat, and use the same day and night colors as the field.

**Fail open.** If Play Billing is missing, the product id is not live yet, `getDetails` or `listPurchases` throws or times out (12 seconds), or Subscribe fails for a reason other than the farmer closing the sheet, the gate goes away and the calculator works. A farmer is not locked out by a glitch. Closing the Play sheet on purpose leaves the gate up. Restore with no subscription stays on the gate and says no active subscription was found on this Google account.

Until the subscription exists on an internal test track, `getDetails` comes back empty and the gate does not stay up. That is the fail-open rule, not a sign that the check was skipped.

`listPurchaseHistory()` is empty with billing 1.2.0 (Play Billing Library 8 removed it). Restore uses `listPurchases()` only, which is the active subscription, including one still in the free trial.

### The helper may ignore the trial offer

`com.google.androidbrowserhelper:billing:1.2.0` buys `subscriptionOfferDetails.get(0)` and does not read `offerId`. Play does not promise which offer is first. The page still sends `offerId: "trial3"` so a helper that learns that field (the unmerged android-browser-helper change is pull request 645) selects the trial without a web edit.

On the first internal test, read the Play sheet before you confirm. It has to say 3 days free, then $24.99 a year. If it charges immediately, this build bought the bare base plan. Do not ship that build.

### Acknowledging the purchase

Play refunds a subscription that is still unacknowledged after three days. The current Digital Goods API has no `acknowledge()` method, and this app has no server. `PlaySubscriptionAck` in the Android wrapper acknowledges an unacknowledged subscription on the device, when the process starts and again when Play's payment activity closes. It does not store the purchase token. `build-release.sh` puts the `Application.onCreate` call back if `bubblewrap update` rewrites that file. Do not delete `PlaySubscriptionAck.java`.

### The free website is a bypass

Anyone who opens `https://randyscustomapps.github.io/strikeout/` in a browser, or who uses Add to Home Screen, gets the calculator with no subscription. The Play app loads that same URL. The gate can only appear after this version of `index.html` is what that URL serves. This branch does not publish the site.

Ways to close the hole, for you to pick. None of them is built here.

1. Leave it. The website is the demo. The Play app is the paid one. A person who already has the URL does not pay. This is the current behavior.
2. Publish the gate on the website too, and point the planned iPhone build at a different check (App Store) later. The website would stop being a free tool the day that page ships.
3. Move the Play app to its own origin (a domain you control) and keep GitHub Pages as the free demo. The gate stays on the Play origin only. Asset links and the TWA host have to move with it.
4. Add a server that Play and the page both trust. That is the only way to make a copied APK or a browser tab fail closed. This app has no server today.

Sideloading the APK is the same hole as the website, because the pages are the public site. Play Integrity and the old Licensing Verification Library are not wired up. Play Integrity wants a server. The Licensing library answers "did they pay to download," which is the wrong question for a free app with a subscription.

## Create the subscription in Play Console

The developer account does not exist yet. Nothing was created in Play, and nothing here was tested against a live product. Do these in order. Ids cannot be renamed after you activate them.

1. Create the app. App name Strikeout Harvest. Set the app to **Free**. Do not set a download price. Package id `com.randyscustomapps.strikeout`, unless you change it in `twa-manifest.json` before the first upload.
2. Finish the payments profile and tax for Randy's Canadian Ltd. Subscriptions will not activate without it. The one-time Play registration fee is separate from the $24.99.
3. Open **Monetize with Play → Products → Subscriptions → Create subscription**.
4. Product id: `strikeout_yearly`. Name: Strikeout Harvest yearly. Description, plain text: Yearly subscription for Strikeout Harvest, with a 3-day free trial. Create it. You cannot change the product id later.
5. **Add base plan**. Base plan id: `yearly`. Type: **Auto-renewing**. Billing period: **1 year** (every 12 months). Set the price for **Canada** to **$24.99 CAD**. Let Play derive other countries, or turn those countries off. Do not add a second base plan. If the page still shows "Backwards compatible" or "Use for deprecated billing methods," turn it on for this base plan. Billing Library 8 does not use that flag; it is there for any older path.
6. On that base plan, turn on a **7-day grace period** so a failed renewal does not drop the farmer off the calculator the same day. Leave account hold off unless you want the gate to come back while a card is declined.
7. **Add offer**. Offer id: `trial3`. Base plan: `yearly`. Eligibility: new customer (never had this subscription). Add one phase: **Free trial, 3 days**. No introductory price after it. The next phase is the base plan, $24.99 CAD a year. Offer the same countries as the base plan, including Canada. A customer who already used `trial3` pays the yearly price if they subscribe again.
8. Activate the base plan, activate the offer, then activate the subscription. An inactive product makes `getDetails` return nothing, and the app then fails open.
9. **Settings → License testing**. Add the Gmail accounts that will install the test build. Those accounts can subscribe without being charged. The sheet still has to show the trial.
10. Upload the AAB to an **internal testing** track and install from that track's opt-in link, with one of those Google accounts, on a phone with Chrome. Billing does not return products to a build that is not on a track. Open the app. You should see the trial screen, then Play's sheet. Confirm the sheet says 3 days free, then $24.99 a year, before anyone pays.
11. After a test purchase, force-close the app and open it again. The calculator should open with no gate. On a second phone with the same Google account, Restore should do the same. A brand-new Google account should still see the gate.

## Store listing and privacy

- Listing copy, content rating, data safety, target age, and the graphic file list: `play/listing.md`
- Privacy policy draft: `play/privacy.html`. Contact email is randyscustomapps@gmail.com. It follows the in-app privacy page and adds the company, the Play purchase, and a contact line.
- Icon, feature graphic, and phone screenshots: `play/graphics/`

## Randy's checklist in Play Console

The developer account does not exist yet. Nothing here was uploaded.

1. Create an **organization** Play Console account for Randy's Canadian Ltd, not a personal account. Organization accounts need a D-U-N-S number for the company. Account type cannot be switched after verification. The one-time Play registration fee is separate from the app price.
2. Confirm the account shows you can publish to production. Google's 12-tester, 14-day closed test is written for personal accounts created after 13 November 2023. The help page does not put organization accounts under that rule. Look at your own console after verification rather than assuming the button is there.
3. Create the app. Set it to **Free**. Decide the package id first (`com.randyscustomapps.strikeout` unless you change it). You cannot change it later. Do not set a download price.
4. Payments profile and tax for the Canadian company, then the subscription in the section above: product `strikeout_yearly`, base plan `yearly`, offer `trial3`, **$24.99 CAD** a year, 3-day free trial.
5. On your machine, run `generate-upload-key.sh`, back up the keystore and `passwords.env` in a password manager, then `build-release.sh`. Upload **that** AAB. Leave Play App Signing on.
6. Copy the **App signing** SHA-256 into asset links and publish the file at `https://randyscustomapps.github.io/.well-known/assetlinks.json` from a `randyscustomapps.github.io` repo (option A above).
7. Store listing from `play/listing.md`. Category Tools. Upload the icon, feature graphic, and screenshots in `play/graphics/`.
8. Privacy policy URL: the hosted `play/privacy.html`. Contact email on that page is randyscustomapps@gmail.com.
9. App content: content rating (Everyone-level, not a game; yes, users can purchase a subscription), target audience 18 and over only, not designed for children, ads No, data safety No collection, location permission foreground and optional, not background.
10. Ship to an internal test track first and open the app on a phone with Chrome. Confirm the Play sheet says 3 days free, then $24.99 a year. Confirm the browser bar is gone after asset links propagate, then promote the release.
