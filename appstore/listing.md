# Strikeout Harvest — App Store listing draft

Paste the blocks below into App Store Connect. Limits are Apple's. The price is a pricing setting, not part of the description, because the store localizes prices.

Nothing in this file was submitted. The app record does not exist yet.

Graphics to upload are listed at the end.

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

The website is free to try in a browser. The App Store app is a one-time purchase of the same calculator.
```

## Keywords

100 characters maximum. Comma-separated, no spaces. Do not repeat the app name. "Strikeout" and "Harvest" are left out on purpose.

**Use:**

```
combine,header,swath,gps,farm,crew,overlap,nudge,lines,field,agriculture,wheat,canola,row
```

89 characters.

## Category

- Primary: **Utilities**
- Secondary: **Productivity**

Utilities matches a single-purpose instrument the operator opens on a pass and closes at the end of the field. Productivity is the other listing that fits a field calculator. Apple has no Tools category. The Play listing uses Tools; this is the App Store equivalent.

## Device

**iPhone only.** Portrait and landscape.

The layout is a phone column made for a cab. Checking iPad in Xcode would require a separate 13-inch iPad screenshot set, and the column would sit in a wide frame. An iPhone-only app can still be installed on an iPad, where iPadOS runs it in a phone-sized window. Add iPad later if a full-size iPad layout is worth it. Do not upload iPad screenshots for this version.

## Pricing

- Price: **C$24.99**, one-time, paid app.
- In App Store Connect, Pricing and Availability, set the Canada price to C$24.99. Let other storefronts follow from that price, or turn off countries you do not want.
- Not a subscription. No in-app purchases. No free trial inside the app. The public website stays free, and that is separate from this price.
- Apple no longer uses the old numbered price tiers. Pick the C$24.99 price point. If that exact amount is missing from the list, pick the closest Canada price Apple offers and do not switch the app to a subscription to force a number.

Do not put the price in the description or the promotional text.

## Age rating

Expected result: **4+**. Do not raise it because the operators are adults. This is not a kids app, and it is not Made for Kids.

Answer the questionnaire like this. Wording in App Store Connect shifts; match the meaning.

| Question | Answer |
| --- | --- |
| Parental controls | No |
| Age assurance | No |
| Unrestricted web access | No. The app is not a browser. It does not open websites. |
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

Apple's collected data is data sent off the device and kept, or used to track the user. Processed on the phone and never sent does not count. Same rule as the Play data-safety answers and `play/privacy.html`.

- Precise location is used only while Auto line advance is on. The app reads GPS position and heading so the current row can advance after a real turnaround. Coordinates stay in memory. They are not written into the saved setup (`strikeout.v1`) and they are not sent anywhere.
- Approximate location is used only when Screen is Auto, to compute sunrise and sunset. It does not use the light sensor. Same rule: memory only, not saved, not sent.
- If Auto is off and Screen is Day or Night, the app does not ask for location.
- There is no account, no analytics, no advertising identifier, no crash vendor, and no payment form. Purchases are Apple's. The app does not receive card data.
- The App Store app does not phone home for pages or for a version check. Updates come from the App Store.
- Header names (optional, such as a first name on a machine) stay on the phone unless the operator uses the iPhone share sheet or a file.

In the privacy form:

| Prompt | Answer |
| --- | --- |
| Do you or your third-party partners collect data from this app? | No |
| Data used to track you | None. Do not use the tracking permission. There is no tracking prompt. |
| Data linked to the user | None |
| Data not linked to the user | None |
| Privacy nutrition label | Data Not Collected |

Do not declare location as collected. The location permission is still in the app, because Auto and Screen Auto need it while the app is open. It is When In Use only. There is no Always / background location.

Privacy policy URL, once this branch is on the public site:

`https://randyscustomapps.github.io/strikeout/appstore/privacy.html`

Until that file is on the `main` branch GitHub Pages serves, the page already live at `https://randyscustomapps.github.io/strikeout/privacy.html` states the same on-device facts (location stays on the phone, no account, no ads). Use the `appstore/privacy.html` URL for the store once it loads in a browser. It adds the company name, the App Store purchase, and the contact email. Apple will not accept a privacy URL that does not open.

## Support, marketing, and contact

| Field | Value |
| --- | --- |
| Support URL | `https://randyscustomapps.github.io/strikeout/` |
| Marketing URL | `https://randyscustomapps.github.io/strikeout/` (optional; same site) |
| Support email | randyscustomapps@gmail.com |
| Phone | Leave blank |
| Copyright | 2026 1594818 B.C. LTD. |
| Seller name on the store | Randy's Custom Apps. See `appstore/README.md` if enrollment shows the legal name instead. |
| SKU | `strikeout-harvest` |
| Bundle ID | `com.randyscustomapps.strikeout` |
| Primary language | English (Canada) |
| Version | 1.0.77 |

## What's new

First version. Apple does not show this text on the first release. Keep it for the next upload.

```
First release. The lead combine's line and nudge card, offline in the cab.
```

## Export compliance

The app does not use custom encryption. `ITSAppUsesNonExemptEncryption` is false in the iOS project, so the upload question should already be answered. If App Store Connect still asks: **No**, the app does not use encryption beyond what Apple's system provides (HTTPS is not in this app; the pages are bundled).

## Review notes

Paste this into App Review Information. There is no demo account.

```
Strikeout Harvest is a field calculator for combine operators. It tells the lead machine how many GPS lines to skip, and how far to nudge, so the crew's return pass finishes the land flush. There is no account, no password, and no sign-in. Open the app and the card is on the first screen.

Please do not treat this as a wrapped website. The pages are inside the app binary. The app does not load https://randyscustomapps.github.io/strikeout/ at runtime. That site is a free demo of the same calculator. Airplane mode works. External links are blocked, except mailto: for the support address in Help.

Location is optional. On first launch, Auto is on, so iOS asks for location. Tap Allow While Using App, or Don't Allow. If you deny it, Auto turns off and the typed current row still works. Coordinates are not saved and are not uploaded. There is no background location.

A sample field, which is what the screenshots show: Randy's header is 40 ft and he is the lead. Pat and Dana, both 40 ft, are following on the right. Joe at 35 ft 1 in didn't follow. Overlap is 6 inches. Current row is 78, numbers count up, turn Right, Skip. The card reads +6 lines, nudge 7 ft 11 in right after the turn, go to 84. A fresh install uses a smaller default crew, not this sample. Settings is where header names and widths are edited.

Send to iPhone opens the system share sheet with strikeout-headers.json. Send to Android phone shares a link to the public demo site so a phone without the app can open it. Import header file uses the system document picker. Keep screen on uses the system idle timer, not a web wake lock. There is no Add to Home Screen step. The app is already installed.

No ads, no account, no in-app purchase. The price is the upfront App Store price.
```

Review contact: randyscustomapps@gmail.com. Sign-in required: **No**.

## Screenshots

Same field as the Play set. Randy 40 ft lead, Pat and Dana 40 ft following on the right, Joe 35 ft 1 in didn't follow, overlap 6 in, row 78 counting up, card +6 lines, nudge 7 ft 11 in right, go to 84. Auto is off in the shots so the card is not waiting on a GPS fix.

PNG, 24-bit, no transparency. No device frame. No status-bar artwork added on top. The app fills the frame, same approach as `play/graphics/screenshots/`.

| Folder | Pixels | App Store slot |
| --- | --- | --- |
| `appstore/screenshots/iphone-6.9/` | 1320×2868 | **6.9-inch iPhone. Upload this set.** Required for the largest iPhone. |
| `appstore/screenshots/iphone-6.7/` | 1290×2796 | 6.7-inch Pro Max size. Apple also accepts these pixels in the 6.9-inch slot. You only need one set in that slot. Prefer the 6.9-inch folder. |
| `appstore/screenshots/iphone-6.5/` | 1284×2778 | **6.5-inch iPhone. Upload this set** if App Store Connect asks for a second iPhone size. |

No iPad screenshots. The app is iPhone only.

Files in each folder, in this order:

| File | Screen |
| --- | --- |
| `01-home-day.png` | Field, day. |
| `02-home-night.png` | Field, night. |
| `03-following.png` | Following sheet. |
| `04-didnt-follow.png` | Didn't follow sheet. |
| `05-settings.png` | Settings, headers. The version line says updates come from the App Store. Check for updates is not shown. |
| `06-settings-screen.png` | Settings, screen and Auto. |
| `07-help.png` | Help, scrolled to Contact support. |

Apple allows up to 10 screenshots. These 7 are enough. Upload the first three at minimum if you want a shorter set: home day, home night, Following.

## Icon

| File | Size | Use |
| --- | --- | --- |
| `appstore/icon-1024.png` | 1024×1024 PNG, no transparency | App Store marketing icon. Upload this in App Store Connect. |
| `ios/Strikeout/Assets.xcassets/AppIcon.appiconset/` | 40, 60, 58, 87, 80, 120, 180, and 1024 | Icons inside the app. Square, not pre-rounded. iOS rounds them. |

The art is the Play icon (`play/graphics/icon-512.png`): flat combine, STRIKEOUT / HARVEST wordmark, brown field. The source pixels are the app's ink brown `#2A1D0A`, gold, and cream. The 1024 file is that art scaled up, flattened so it has no alpha channel. Do not add rounded corners or a drop shadow before upload. Apple rejects marketing icons that have transparency.

The launch screen is the same mark, centered, on the day background `#F2DFA7`. It is not a timed splash. The calculator appears as soon as the app opens.
