# Strikeout Harvest — App Store listing draft

Paste the blocks below into App Store Connect. Limits are Apple's. Nothing in this file was submitted. The app record does not exist yet.

Graphics to upload are listed at the end. The owner steps are in `appstore/README.md`.

## App name

30 characters maximum.

**Use:** Strikeout Harvest

17 characters.

## Subtitle

30 characters maximum.

**Use:** Skip GPS lines. Finish flush.

29 characters.

## Promotional text

170 characters maximum. This can be changed later without a new app version.

**Use:**

```
Tells the lead combine how many GPS lines to skip, and how far to nudge, so the return pass finishes flush. Works offline in the cab. No account.
```

145 characters.

## Description

4000 characters maximum. Paste as plain text. This draft is the block between the fences.

```
Strikeout Harvest tells the lead combine how many GPS lines to skip, and how far to nudge, so the crew's return pass finishes the land flush.

You are on a line. The others are out with you, or they are not. Strikeout Harvest turns header widths, overlap, and who is actually in the pass into one card: the line to go to, and a nudge left or right after the turn.

On the pass
Enter the GPS line you are on now, including the first pass. Count up or count down. Go to is that line plus or minus the move. On 78 with +6, count up, you go to 84.

Turning at the end is Left or Right, the way you leave the pass you are driving. North, then east to come back south, is Right.

Following me means they are out with you. Pick their side, usually Right, then Skip or Outside. Skip jumps the pack: followers out, then the whole crew back. Outside leaves room for the followers only, so the crop stays outside.

Not following means you go out alone. Count the others. Skip, Outside, and Didn't follow stay on the screen but are not used until Following me is on again.

Didn't follow is for the ones who peeled off while the rest are with you. Each header is added once, at that header's own width. A 35 ft machine and a 40 ft machine are not forced onto one size.

Overlap is taken off every head. Step it by a half inch, one inch, or three inches. Your GPS lines are spaced at your header width. Everyone's cut counts as header width minus overlap.

The card shows whichever way needs the smaller nudge. The nudge is left or right after the turn, on the new heading, so it matches the GPS arrows. Farther out is away from cut land. Back in is toward it. Add it to any nudge already set.

Headers
Widths are feet and inches, such as 35 ft 1 in. My header is your GPS line width. The same width with a different name is a different header. Send the list to an Android phone or an iPhone in the crew. Import can keep yours and add the new ones, or replace the list. Overlap, the current row, and the rest of the field stay put.

When every header matches yours and overlap is zero, Following me plus Skip is two times the others plus one. Two others is +5 lines. Outside, or Not following, is the others plus one.

Auto
Auto reads North-South or East-West from the GPS heading. There is nothing else to set. After a real turnaround, the current row advances once you have driven the confirm distance the new way: 50, 100, or 150 feet. A short reverse, such as for plugged crop, does not. If location is denied, Auto turns off and the typed row still works.

Screen
Day, Night, or Auto. Auto follows sunrise and sunset from your location. It does not use the light sensor. Extra-dim night is for the cab after dark. Keep screen on holds the display awake while you are in the field.

On the iPhone
The App Store app keeps its pages inside the app. It does not open the website, and it does not need a cell signal in the cab. Header sizes, crew counts, and the current row stay on this iPhone. They are not uploaded. There is no account, and there are no ads.

Sending a header list uses the iPhone share sheet. Import uses the Files picker. The phone can stay awake while you are on the pass.

Subscription
The app is free to download. New subscribers get a 3-day free trial, then $24.99 CAD a year. The subscription lasts one year and renews automatically until you cancel. Payment is charged to your Apple ID at confirmation, and again within 24 hours before each renewal. Cancel anytime in Settings, then Apple ID, then Subscriptions.

Privacy Policy: https://strikeoutharvest.com/appstore/privacy.html
Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

## Keywords

100 characters maximum. Comma-separated, no spaces. Do not repeat the app name. Strikeout and Harvest are left out on purpose.

**Use:**

```
combine,header,swath,gps,farm,crew,overlap,nudge,lines,field,agriculture,wheat,canola,row
```

89 characters.

## Category

- Primary: **Utilities**
- Secondary: **Productivity**

Utilities matches a single-purpose instrument the operator opens on a pass and closes at the end of the field. Productivity is the other listing that fits a field calculator. Apple has no Tools category. The Play listing uses Tools. This is the App Store equivalent.

## Device

**iPhone only.** Portrait and landscape. Not iPad.

The layout is a phone column for a combine cab: big buttons, one hand, mounted beside the GPS. Supporting iPad properly would mean a tablet layout and a 13-inch screenshot set. This version does not claim iPad. An iPhone-only app can still open on an iPad in Apple's compatibility window. Do not upload iPad screenshots. Add iPad later only if a full-size iPad layout is worth building.

## Pricing and the subscription

The download is **free**. The charge is one auto-renewing subscription. Do not set a paid download price. A paid download cannot offer the 3-day trial.

- Subscription group name: **Strikeout Harvest**
- Product id: `com.randyscustomapps.strikeout.yearly`
- Duration: **1 year**
- Canada price: **$24.99 CAD**. Set the Canada price yourself. Let other countries follow, or turn off countries you do not want.
- Introductory offer: **free trial, 3 days**, for new subscribers. One introductory offer. No second plan.
- Family Sharing: off.

The steps to create it are in `appstore/README.md`. The local test file is `ios/Strikeout/Strikeout.storekit`.

## Subscription display name and description

Paste these into the subscription localization. English (Canada).

Display name, 30 characters maximum:

**Strikeout Harvest yearly**

24 characters.

Description, 45 characters maximum:

**Yearly access, with a 3-day free trial.**

39 characters.

## Age rating

Expected result: **4+**. Do not raise it because the operators are adults. This is not a kids app, and it is not Made for Kids. The subscription is a purchase. It is not a content category.

Answer the questionnaire like this. Wording in App Store Connect shifts. Match the meaning.

| Question | Answer |
| --- | --- |
| Parental controls | No |
| Age assurance | No |
| Unrestricted web access | No. The app is not a browser. It does not open websites inside the app. Legal links open in Safari. |
| User-generated content | No. Header names stay on the phone. Nothing is posted for other people to browse inside the app. |
| Messaging and chat | No |
| Advertising | No |
| Gambling, contests, loot boxes | No |
| Violence, realistic or cartoon | None |
| Sexual content or nudity | None |
| Profanity or crude humor | None |
| Horror or fear | None |
| Alcohol, tobacco, or drugs | None |
| Mature or suggestive themes | None |
| Medical or treatment information | No |
| Guns or weapons | None |
| Made for Kids | No |

The share sheet hands a header file to whatever app the operator picks (Messages, Mail, Files). That is the iPhone share sheet, not chat inside Strikeout Harvest. If a question says that any sharing at all counts, answer only that narrow item Yes, then No to in-app chat, public posting, and moderation. There is nothing posted to Strikeout Harvest, so there is nothing to moderate.

## App Privacy

Answer **Data Not Collected.**

Apple's collected data is data sent off the device. Processed on the iPhone and never sent does not count. Checked against the app:

- Precise location is used only while Auto line advance is on. The watch reads GPS position and heading so the current row can advance after a real turnaround. Coordinates stay in memory. They are not written into the saved setup (`strikeout.v1`) and they are not sent anywhere.
- Approximate location is used only when Screen is Auto, to compute sunrise and sunset. It does not use the light sensor. Same rule: memory only, not saved, not sent.
- If Auto is off and Screen is Day or Night, the app does not ask for location.
- There is no account, no analytics, no advertising identifier, and no payment form. Apple bills the subscription. The app does not receive card data. It stores, on this iPhone only, that a subscription was verified and the date it runs until, so the calculator still opens with no signal. That note is not uploaded.
- The pages are inside the app. The App Store app does not fetch `version.json`.

Do not declare location as collected. The usage string still has to say what location is for, because the app can ask for it. That string is in `ios/Strikeout/Info.plist`.

Privacy policy URL, once the marketing site is up:

`https://strikeoutharvest.com/appstore/privacy.html`

The file is `appstore/privacy.html`. Open that URL in a browser before you paste it. Support URL is `https://strikeoutharvest.com`. Support email is support@strikeoutharvest.com.

Terms of Use: Apple's standard EULA. The paywall and the description link to `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`. In App Store Connect, leave the custom EULA empty so the standard one applies.

## App Review notes

Paste this into App Review Information. There is no demo account.

```
Strikeout Harvest is a combine-cab calculator. The pages are bundled in the app and load from strikeout://app/. The app does not browse the web. http and https links are not loaded in the app. The Privacy Policy and Apple's standard Terms of Use open in Safari when tapped on the paywall.

The download is free. There is one auto-renewing subscription, product id com.randyscustomapps.strikeout.yearly, in the subscription group Strikeout Harvest. It is $24.99 CAD a year, with a 3-day free introductory offer for a new subscriber.

How to test the purchase:
1. Sign in with a Sandbox Apple ID (App Store Connect, Users and Access, Sandbox).
2. Open the app. The first screen is the 3-day free trial, the yearly price, Restore Purchases, Manage subscription, and links to the Privacy Policy and Terms of Use.
3. Tap Start free trial. The App Store sheet should show 3 days free, then the yearly price. Confirm it.
4. The calculator opens. Settings has Manage subscription, which opens Apple's subscription sheet.
5. To test the offline case: subscribe once with signal, then turn on Airplane Mode and open the app again. The calculator should open. A previously verified subscription keeps working with no signal until it expires. A phone that has never subscribed stays on the trial screen and needs a connection to start it.

Location is optional. You can deny it. The line card still works with a typed row. Allow While Using App is used only while Auto line advance is on, or while Screen is set to Auto (sunrise and sunset). The app does not use location in the background.

A local StoreKit configuration file, ios/Strikeout/Strikeout.storekit, is attached to the Xcode scheme for a simulator run. It is not shipped in the App Store build. TestFlight uses the real product in App Store Connect.

There is no login. Sample field, if you want the same card as the screenshots: Randy 40 ft is the lead. Pat and Dana, both 40 ft, are following on the right. Joe at 35 ft 1 in didn't follow. Overlap is 6 inches. Current row is 78, count up. The card reads +6 lines, nudge 7 ft 11 in right, go to 84.
```

## What makes this an app

For the reviewer, and for guideline 4.2. This is not a website in a box.

- The calculator is copied into the app at build time and served from `strikeout://app/`. It does not load strikeoutharvest.com.
- The purchase is StoreKit. The confirmation sheet is Apple's.
- Send to Android phone and Send to iPhone use the system share sheet.
- Import header file uses the Files picker. A header JSON opened from another app imports the same way.
- Keep screen on uses the system idle timer.
- Buttons use haptic feedback.
- The status bar and the safe area follow the app's Day and Night, including the Dynamic Island, the notch, and the home indicator, in portrait and landscape.
- Add to Home Screen and the service-worker update check are not shown. Updates are App Store updates.

## Store graphics

Screenshots are 24-bit PNG, no alpha. The icon is 24-bit PNG, no alpha.

Apple's current required iPhone slot is **iPhone with Dynamic Island (medium display)**, 1206 × 2622. **iPhone with Dynamic Island (large display)**, the 6.9-inch size, is the other set you should upload. If that large set is missing, Apple requires the 6.5-inch set instead. This folder has both. iPad screenshots are not included, because the app is iPhone only.

| File | Size | Use |
| --- | --- | --- |
| `appstore/icon-1024.png` | 1024×1024 PNG | Marketing icon. No transparency. iOS rounds it. |
| `appstore/screenshots/iphone-6.9/` | 1320×2868 | Dynamic Island, large display. 6.9 inch. |
| `appstore/screenshots/iphone-6.3/` | 1206×2622 | Dynamic Island, medium display. Required slot. |

Seven shots in each folder, same order:

| File | What it shows |
| --- | --- |
| `01-home-day.png` | Field, day. |
| `02-home-night.png` | Field, night. |
| `03-following.png` | Following sheet. |
| `04-didnt-follow.png` | Didn't follow sheet. |
| `05-settings.png` | Settings, headers. |
| `06-settings-screen.png` | Settings, screen and Auto. |
| `07-help.png` | Help, scrolled to Contact support. |

Sample field in every shot, the same one as the Play screenshots: Randy's header is 40 ft and he is the lead. Pat and Dana, both 40 ft, are following on the right. Joe at 35 ft 1 in didn't follow. Overlap is 6 inches. Current row is 78, numbers count up. The card reads +6 lines, nudge 7 ft 11 in right after the turn, go to 84. Auto is off so the card is not waiting on a GPS fix. Screen is Day in the day shots and Night in the night shot.

`appstore/scripts/capture.mjs` reshoots these from the bundled page after `ios/scripts/sync-web.sh`. The committed PNGs are the ones to upload.
