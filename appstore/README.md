# App Store checklist

This is the list for Randy. The project does not enroll, does not pay Apple, does not create the app record, and does not submit for review. Signing commands and the TestFlight upload are in `ios/README.md`. Do the steps in this order.

The company is **1594818 B.C. LTD.**, Fort St. John, BC. D-U-N-S **250990975**. The download is free. One subscription: **$24.99 CAD a year**, with a **3-day free trial** for a new subscriber. Contact is **support@strikeoutharvest.com**. The marketing site will be **https://strikeoutharvest.com**.

## 1. Enroll as the company

1. The D-U-N-S number is 250990975. On the Apple enrollment form, the legal name has to match Dun & Bradstreet: **1594818 B.C. LTD.** Copy the periods and the spaces.
2. Enroll in the Apple Developer Program as an **Organization**, not as an individual. The fee is **US$99 per year**, paid to Apple. You have to be someone who can bind the company.
3. Organization and individual cannot be swapped later without a painful move. Start as the company.
4. If Apple asks what customers should see as the seller, use **Randy's Custom Apps**. If the store shows 1594818 B.C. LTD. instead, that is the legal name. A seller-name change is a request to Apple Developer Support after the account exists. Do not enroll under a personal name to get the shorter label.

## 2. Create the app record

After Apple approves the account:

1. Certificates, Identifiers & Profiles → Identifiers → App IDs → Explicit. Bundle ID: `com.randyscustomapps.strikeout`. You cannot change it after the first upload. No push, no iCloud, no associated domains.
2. App Store Connect → Apps → New App.
   - Name: Strikeout Harvest
   - Bundle ID: the one you just registered
   - SKU: `strikeout-harvest`
   - Primary language: English (Canada)
   - User Access: full
3. The download price stays free. The money is the subscription in step 4.

## 3. Agreements, tax, and banking

A free app with a subscription still needs the **Paid Apps** agreement. Without it, the subscription cannot be sold and TestFlight purchase tests do not run.

1. App Store Connect → Agreements, Tax, and Banking → Paid Apps → set up.
2. Bank account: the company's **RBC** account. Apple pays the company, not a personal account.
3. Tax: 1594818 B.C. LTD. is a Canadian corporation, not a US person. Apple's interview for a foreign company is **Form W-8BEN-E**. That is the entity form. Do not use W-9. Do not use W-8BEN. That one is for an individual. Complete the interview in App Store Connect. This project does not fill the form in.

## 4. Create the subscription

One group. One product. One introductory offer.

1. In the app, Subscriptions → create a group named **Strikeout Harvest**.
2. Create a subscription. Reference name: Strikeout Harvest yearly. Product id, exactly: `com.randyscustomapps.strikeout.yearly`. You cannot change the product id later.
3. Duration: **1 year**.
4. Subscription price: add a price. Set Canada to **$24.99 CAD**. Let other countries follow, or turn off countries you do not want.
5. Localization, English (Canada). Display name: **Strikeout Harvest yearly**. Description: **Yearly access, with a 3-day free trial.** The description field allows 45 characters. That line is 39.
6. Introductory offer: free, **3 days**, for new subscribers (people who have not subscribed to this group before). One offer. Do not add a second plan or an introductory price after the trial.
7. Family Sharing: off.
8. The local Xcode file `ios/Strikeout/Strikeout.storekit` uses the same product id, the same yearly period, and the same 3-day free trial, with the Canada storefront. It is for a simulator run. It is not what customers buy.

## 5. Listing, privacy, and support

1. Host `appstore/privacy.html` so this URL loads in a browser: `https://strikeoutharvest.com/appstore/privacy.html`. Open it before you paste it. If it does not load, Apple will not take the record. This project does not publish the site.
2. Privacy Policy URL: that address.
3. Support URL: `https://strikeoutharvest.com`
4. Support email: support@strikeoutharvest.com
5. Terms of Use: leave the custom EULA empty. The standard Apple EULA applies. The description and the paywall already link to it.
6. Paste the name, subtitle, promotional text, description, and keywords from `appstore/listing.md`.
7. Category: **Utilities**. Secondary: Productivity.
8. Age rating: the table in `appstore/listing.md`. It should come out 4+.
9. App Privacy: **Data Not Collected.**
10. Upload `appstore/icon-1024.png` and the screenshots in `appstore/screenshots/iphone-6.9/` and `appstore/screenshots/iphone-6.3/`. Do not upload iPad screenshots. The app is iPhone only.
11. App Review Information: paste the review notes from `appstore/listing.md`. There is no demo login. Contact phone and email are yours. Sign-in required: no.

## 6. Signing secrets, then TestFlight

The unsigned compile check does not sign the app and does not upload. Uploading needs the seven secrets in `ios/README.md`. Add them to the GitHub repository as Actions secrets, then run the workflow named **iOS App Store** by hand.

That workflow builds the app and uploads it to TestFlight. It does not submit the app for review. Install it from TestFlight with a Sandbox Apple ID and read the sheet before anyone pays. The sheet should say 3 days free, then $24.99 CAD a year.

## 7. Submit only when you mean to

The review button is yours. The notes for the reviewer are in `appstore/listing.md`.

## What this app is

It is the Strikeout Harvest calculator, packaged so the pages travel inside the iPhone app and the subscription is StoreKit. It is not a browser pointed at the website. The Android app is a separate install and uses Google Play Billing. The iPhone app does not use that.

Version on this branch is **1.0.81**, build 1. That matches the web app version already on the Play subscription branch. The shared `index.html` was not edited for this shell, so that version number was not raised.
