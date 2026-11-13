# Strikeout Harvest on Google Play

Draft launch assets for the Android app. The Play app is free to install and sells a yearly subscription through Google Play Billing. The public page at `https://randyscustomapps.github.io/strikeout/` becomes a Play store link on launch day. The calculator moves to its own origin, `https://app.strikeoutharvest.com/`. The subscription gate lives in `index.html` and runs only inside this Trusted Web Activity.

The Android package is a Trusted Web Activity: a thin app that opens the app origin in Chrome, fullscreen, once Digital Asset Links check out. Bubblewrap 1.25.0 generated `play/android/` from the web manifest.

## Package name — change it before the first upload

Suggested application id: **`com.randyscustomapps.strikeout`**

It is only a suggestion. Play locks the id at the first upload, and it cannot be renamed later. If you want a different id, change `packageId` in `play/android/twa-manifest.json`, run `bubblewrap update --skipVersionUpgrade` inside `play/android/`, and use the same id in `.well-known/assetlinks.json` and `play/.well-known/assetlinks.json`. Do that before anyone uploads an AAB.

## What the Android project is

| | |
| --- | --- |
| Start URL | `https://app.strikeoutharvest.com/` |
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

Chrome only treats the app as a Trusted Web Activity after it finds a statement for this package on the **app origin root**:

`https://app.strikeoutharvest.com/.well-known/assetlinks.json`

The file in this repo is `.well-known/assetlinks.json`. GitHub Pages serves it from the app repo root. `.nojekyll` is there so Pages does not hide the dot folder. `Content-Type` must be `application/json`, over HTTPS, with no login and no redirect to HTML.

`play/.well-known/assetlinks.json` is the same template. One GitHub repo has one Pages site, so this file is published from `randyscustomapps/strikeout-app`, not from the strikeout project site. Do not point the TWA at `randyscustomapps.github.io`.

`CNAME` in the app repo contains `app.strikeoutharvest.com`. To use a different host, run `play/set-app-origin.sh new-host.example` before you build. The hostname currently written down is `play/app-origin.txt`.

### Which SHA-256

After the first upload, Play App Signing is on by default. Phones receive an APK signed by **Google's app signing key**, not by your upload key.

1. Play Console → Test and release → App integrity → App signing.
2. Copy the SHA-256 of the **App signing key certificate**.
3. Put that string in `sha256_cert_fingerprints` in `.well-known/assetlinks.json` and `play/.well-known/assetlinks.json`, colons included, uppercase hex as Play shows it.
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

The gate runs only when the page was opened as this Play app. Chrome sets `document.referrer` to `android-app://com.randyscustomapps.strikeout` on that launch. A reload in the same tab keeps a `sessionStorage` flag named `strikeout.playtwa` so the gate can come back after the referrer is gone. That flag is not the settings key `strikeout.v1`, and it is not written for a normal browser tab. Opening the app origin in Chrome, or from an iPhone home-screen icon, does not take this path. That is how a browser test of the calculator works.

Inside the Play app, with no active subscription, the farmer gets one full-screen page: 3-day free trial, then $24.99 CAD a year, a Subscribe button, and a Restore button. The buttons are tall, flat, and use the same day and night colors as the field.

**Fail open.** If Play Billing is missing, the product id is not live yet, `getDetails` or `listPurchases` throws or times out (12 seconds), or Subscribe fails for a reason other than the farmer closing the sheet, the gate goes away and the calculator works. A farmer is not locked out by a glitch. Closing the Play sheet on purpose leaves the gate up. Restore with no subscription stays on the gate and says no active subscription was found on this Google account.

Until the subscription exists on an internal test track, `getDetails` comes back empty and the gate does not stay up. That is the fail-open rule, not a sign that the check was skipped.

`listPurchaseHistory()` is empty with billing 1.2.0 (Play Billing Library 8 removed it). Restore uses `listPurchases()` only, which is the active subscription, including one still in the free trial.

### The helper may ignore the trial offer

`com.google.androidbrowserhelper:billing:1.2.0` buys `subscriptionOfferDetails.get(0)` and does not read `offerId`. Play does not promise which offer is first. The page still sends `offerId: "trial3"` so a helper that learns that field (the unmerged android-browser-helper change is pull request 645) selects the trial without a web edit.

On the first internal test, read the Play sheet before you confirm. It has to say 3 days free, then $24.99 a year. If it charges immediately, this build bought the bare base plan. Do not ship that build.

### Acknowledging the purchase

Play refunds a subscription that is still unacknowledged after three days. The current Digital Goods API has no `acknowledge()` method, and this app has no server. `PlaySubscriptionAck` in the Android wrapper acknowledges an unacknowledged subscription on the device, when the process starts and again when Play's payment activity closes. It does not store the purchase token. `build-release.sh` puts the `Application.onCreate` call back if `bubblewrap update` rewrites that file. Do not delete `PlaySubscriptionAck.java`.

### Public page, app origin, and the test copy

The public URL becomes a store page when the store-page pull request is merged to `main`. Do not merge this branch to `main`. This branch is the calculator. `main` becomes the store page.

`strikeout.v1` is stored per origin. The app origin is not `github.io`, so header sizes and the current row on a phone that used the old site do not show up in the Play app. There is no copy step. The farmer sets the headers again.

Open `https://app.strikeoutharvest.com/` in Chrome to test the calculator. The gate stays off, because that visit is not the Play app. GitHub Pages publishes one branch, so there is no separate preview URL. Put a new build on `strikeout-app` only when it is the build the Play app should load.

The source stays public either way. `strikeout-app` has to be a public repo, because GitHub's free plan does not serve Pages from a private repo. This repo stays public too. The host is in `play/app-origin.txt` and `twa-manifest.json`. Anyone who reads either repo can open the calculator. An obscure URL would not be security, and this URL is not obscure. `robots.txt` asks crawlers to skip the app pages and still allows `/.well-known/`. That does not stop a person.

Sideloading the APK still opens whatever URL is in the package. Play Integrity wants a server this app does not have.

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
- Privacy policy draft: `play/privacy.html`. Contact email is support@strikeoutharvest.com. It follows the in-app privacy page and adds the company, the Play purchase, and a contact line.
- Icon, feature graphic, and phone screenshots: `play/graphics/`

## Randy's checklist in Play Console

The developer account does not exist yet. Nothing here was uploaded.

1. Create an **organization** Play Console account for Randy's Canadian Ltd, not a personal account. Organization accounts need a D-U-N-S number for the company. Account type cannot be switched after verification. The one-time Play registration fee is separate from the app price.
2. Confirm the account shows you can publish to production. Google's 12-tester, 14-day closed test is written for personal accounts created after 13 November 2023. The help page does not put organization accounts under that rule. Look at your own console after verification rather than assuming the button is there.
3. Create the app. Set it to **Free**. Decide the package id first (`com.randyscustomapps.strikeout` unless you change it). You cannot change it later. Do not set a download price.
4. Payments profile and tax for the Canadian company, then the subscription in the section above: product `strikeout_yearly`, base plan `yearly`, offer `trial3`, **$24.99 CAD** a year, 3-day free trial.
5. On your machine, run `generate-upload-key.sh`, back up the keystore and `passwords.env` in a password manager, then `build-release.sh`. Upload **that** AAB. Leave Play App Signing on.
6. Copy the **App signing** SHA-256 into `.well-known/assetlinks.json` on this branch and redeploy the app origin. Chrome reads `https://app.strikeoutharvest.com/.well-known/assetlinks.json`.
7. Store listing from `play/listing.md`. Category Tools. Upload the icon, feature graphic, and screenshots in `play/graphics/`.
8. Privacy policy URL: the hosted `play/privacy.html`. Contact email on that page is support@strikeoutharvest.com.
9. App content: content rating (Everyone-level, not a game; yes, users can purchase a subscription), target audience 18 and over only, not designed for children, ads No, data safety No collection, location permission foreground and optional, not background.
10. Ship to an internal test track first and open the app on a phone with Chrome. Confirm the Play sheet says 3 days free, then $24.99 a year. Confirm the browser bar is gone after asset links propagate, then promote the release.

## Where the app is published

One GitHub repo has one Pages site. The strikeout repo's Pages site is the public store page (`https://randyscustomapps.github.io/strikeout/`). It cannot also be `https://app.strikeoutharvest.com/`.

Create a second **public** repo, `randyscustomapps/strikeout-app`, on launch day. Publish this branch's files from the root of that repo (the calculator, `CNAME`, `.nojekyll`, and `.well-known/assetlinks.json`). Set that repo's Pages custom domain to `app.strikeoutharvest.com`. Leave the strikeout repo's Pages domain alone.

The source is public in both repos. A private repo cannot serve Pages on the free plan.

Later, the store page can also live at `https://strikeoutharvest.com/`. That is a different custom domain on the strikeout repo, with GitHub's apex A records at Porkbun. It is not part of this change. Leave the apex alone for now, and do not change the MX or SPF records.

## Porkbun DNS

Nameservers stay on Porkbun. Add one record. Do not edit the MX or SPF records that forward mail.

| Type | Host | Answer |
| --- | --- | --- |
| CNAME | `app` | `randyscustomapps.github.io` |

## GitHub domain check, then Pages

Verify the domain on the GitHub account before anyone else can attach it to a Pages site. GitHub makes the TXT value when you add the domain. It is not in this repo.

1. GitHub → Settings → Pages → Add a domain. Enter `strikeoutharvest.com` (the apex). Verifying the apex covers `app`.
2. GitHub shows a TXT record. The host is `_github-pages-challenge-randyscustomapps`. The value is the string GitHub shows on that screen.
3. At Porkbun, add that TXT record. Do not change MX or SPF. Click Verify on GitHub.
4. Create the public repo `randyscustomapps/strikeout-app` and push this app tree to the branch Pages will publish. The root must include `CNAME`, `.nojekyll`, and `.well-known/assetlinks.json`.
5. In that repo, Settings → Pages → Deploy from that branch. Custom domain: `app.strikeoutharvest.com`. Save.
6. Wait until the certificate is issued. Then check **Enforce HTTPS**. Leave it unchecked until GitHub offers the box. DNS can take a while. The certificate often follows within an hour and can take longer.

## Launch day

Do this when the Play listing is ready. Until then, leave both pull requests unmerged. `main` keeps serving the calculator.

1. Add the Porkbun CNAME above, and the GitHub verification TXT. Do not touch MX or SPF.
2. Create `randyscustomapps/strikeout-app`, push this app tree, and turn on Pages with the custom domain and Enforce HTTPS, as above.
3. Open `https://app.strikeoutharvest.com/` in Chrome. The calculator should load and the subscription gate should stay off. `https://app.strikeoutharvest.com/.well-known/assetlinks.json` should be JSON, not a 404.
4. Build the AAB from this branch and upload it. The start URL is `https://app.strikeoutharvest.com/`.
5. Merge the store-page pull request (#73) into `main`. That is the flip. `https://randyscustomapps.github.io/strikeout/` becomes the Play button. Do not merge this branch into `main`.
6. Open an old home-screen icon once with signal. It should show the store page. After that, offline shows the store page too. A phone that never connects keeps the cached calculator.
7. Open the Play app. It should show the calculator from `https://app.strikeoutharvest.com/`, then the trial screen when billing is live.
