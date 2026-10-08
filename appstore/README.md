# Strikeout Harvest on the App Store

This folder is the store listing for the iPhone app. The iPhone project itself is in `ios/`. The website at `https://randyscustomapps.github.io/strikeout/` stays the free demo. Nothing here changes that site.

Nothing has been paid for, and nothing has been sent to Apple. There is no Apple Developer account yet, and there is no app record in App Store Connect.

## What is already done

- An iPhone app named **Strikeout Harvest**. It contains the calculator inside the app, so it runs in the cab with no cell signal. It does not open the website.
- The bundle id is `com.randyscustomapps.strikeout`. The version matches the site: 1.0.77.
- Portrait and landscape. iPhone only.
- Sending a header list uses the iPhone share sheet. Import uses the Files picker. Keep screen on keeps the phone awake. The home-screen install instructions from the website are not shown inside the app.
- The icon, the launch screen, and the screenshots.
- A check that the app compiles, running on a Mac that GitHub provides. You do not need to buy a Mac for that check. See the pull request for the result.
- The words to paste into App Store Connect, in `appstore/listing.md`.

## What you do, in this order

Do these yourself. A helper can do step 4 from `ios/README.md` on any computer. You still do not need to buy a Mac.

1. **Wait for the D-U-N-S number** for the company. The legal name on that record should be **1594818 B.C. LTD.** Copy it exactly as Dun & Bradstreet prints it, including periods and spaces.

2. **Enroll in the Apple Developer Program as an Organization**, not as an individual. The fee is **US$99 per year**, paid to Apple, not from this project. Use the D-U-N-S number and the legal name. You have to be someone who can bind the company. The public site `https://randyscustomapps.github.io/strikeout/` is the website Apple may look at. Organization and individual cannot be swapped later without a painful move, so start as the company.

   The name customers see under the app is the seller name. During enrollment, if Apple asks what customers should see, use **Randy's Custom Apps**. If the store shows **1594818 B.C. LTD.** instead, that is the legal name, and a seller-name change is a request to Apple Developer Support after the account exists. Do not enroll under a personal name to get the shorter label.

3. **After Apple approves the account**, in App Store Connect create the app:
   - Name: Strikeout Harvest
   - Bundle ID: `com.randyscustomapps.strikeout` (register this exact id under Certificates, Identifiers & Profiles first; it cannot be changed after the first upload)
   - SKU: `strikeout-harvest`
   - Language: English (Canada)

4. **Signing.** The compile check does not sign the app. Uploading to Apple requires a distribution certificate, a provisioning profile, and an App Store Connect API key. The names of the seven secrets, and how to make the files without a Mac, are in `ios/README.md`. Add them to the GitHub repository as Actions secrets. Then run the workflow named **iOS App Store** by hand. It builds an installable file and keeps it. It does not upload that file to Apple.

5. **Paste the listing** from `appstore/listing.md`. Upload the icon `appstore/icon-1024.png` and the screenshots in `appstore/screenshots/`. Price **C$24.99**, one time, not a subscription. Age rating from the table in the listing (it should come out 4+). App Privacy: **Data Not Collected**.

6. **Privacy policy URL.** Put this branch on the public site first, then use `https://randyscustomapps.github.io/strikeout/appstore/privacy.html`. Open that link in a browser before you paste it. If it does not load, Apple will reject the record. Support URL is `https://randyscustomapps.github.io/strikeout/`. Support email is randyscustomapps@gmail.com.

7. **Submit for review only when you mean to.** This project does not press that button. The notes for the reviewer are in `appstore/listing.md`. There is no test login. Tell the reviewer the app is a combine calculator and that location can be denied.

## What this app is, in one paragraph

It is the same Strikeout Harvest calculator as the website, packaged as an iPhone app that works offline. Apple sometimes rejects an app that is only a website in a box. This one is built so the pages travel inside the app, sharing uses the iPhone's own share sheet, and it does not browse the web. A reviewer can still say no. If that happens, the review notes are the place to answer, not a rewrite of the calculator.

## Where the files are

| What | Where |
| --- | --- |
| Words for the store | `appstore/listing.md` |
| Privacy page for the store URL | `appstore/privacy.html` |
| Icon to upload | `appstore/icon-1024.png` |
| Screenshots | `appstore/screenshots/iphone-6.9/`, `iphone-6.7/`, `iphone-6.5/` |
| The iPhone project | `ios/` |
| Signing steps for a helper | `ios/README.md` |
| Play listing, already drafted | `play/` |
