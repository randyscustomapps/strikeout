# Strikeout Harvest — Play Store listing draft

Paste the blocks below into Play Console. Limits are Google's. The price is a console setting, not part of the description, because Play localizes prices.

Graphics to upload are in `play/graphics/`. See the file list at the end.

## App name

Play allows 30 characters.

**Use:** Strikeout Harvest

17 characters. The limit is 30.

The in-app header is heavy STRIKEOUT with small gold HARVEST between thin gold rules. The Android launcher label is Strikeout, the web manifest `short_name`, so the name fits under the icon. The store name is the full Strikeout Harvest.

## Short description

80 characters maximum. This draft is 66.

```
Skip GPS lines and nudge so the crew's return pass finishes flush.
```

## Full description

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

On the phone
Open it once with signal. After that it runs with no cell service. Header sizes, crew counts, and the current row stay on this phone. They are not uploaded. There is no account, and there are no ads.

The website is free to try in a browser. The Play Store app is a one-time purchase of the same calculator, installed like any other app.
```

## Category

**Tools.**

Productivity is the other listing that fits a field calculator. Tools matches a single-purpose instrument the operator opens on a pass and closes at the end of the field.

## Pricing

- App type: **Paid** (one-time). Not free, not a subscription, no in-app products.
- Price: **about $24.99 CAD** in Canada. Set the Canada price explicitly. Let Play derive other countries, or turn off countries you do not want.
- The public site stays free. Do not put the price in the description.

## Content rating

App type: **not a game**. In the IARC questionnaire, choose the utility / all-other-apps path, not a game category.

| Question | Answer |
| --- | --- |
| Violence | No |
| Sexual content or nudity | No |
| Language / profanity | No |
| Controlled substances (alcohol, tobacco, drugs) | No |
| Users interact or exchange content inside the app | No. See the note under the table. |
| Shares the user's location with other users | No |
| Users can purchase digital goods inside the app | No. The store price is not an in-app product. |
| Web browser or search engine | No. The app opens one site. It is not a general browser. |
| User-generated content that other people can browse or that is shared publicly | No |
| Unrestricted internet, social, or chat | No |

Header share: Settings can hand header names and widths to the phone's share sheet, or to a file the operator sends. Strikeout Harvest does not host that message, does not have profiles, and does not show anyone else's content. If a question's wording says that any sharing at all counts, answer Yes only to that narrow item, then No to public posting, in-app chat, and moderation. Nothing is posted to Strikeout Harvest, so there is nothing to moderate.

Expected certificate: Everyone / PEGI 3 / low maturity. That is the content rating. It is separate from target age. Do not raise the content rating just because the operators are adults.

## Target audience and content

- Age groups: **18 and over only.** Do not tick under 13, 13–15, or 16–17.
- Could the store listing or the app appeal to children? **No.**
- Designed for children / Families program: **No.**
- Ads: **No.** The app does not contain ads.

Strikeout Harvest is a field tool for people running combines and harvest crews.

## Ads and the other App content declarations

- Ads: No.
- News app: No.
- COVID-19 contact tracing or status: No.
- Government app: No.
- Financial features: No. Google Play bills the one-time price. The app does not move money, offer loans, or show crypto.
- Health: No.

## Data safety

Answer the overview question **No: this app does not collect or share any of the required user data types.**

Play's definition of collected is data transmitted off the device. Processed on the phone and never sent does not count as collected. Checked against the app:

- Precise location is used only while Auto line advance is on. The watch reads GPS position and heading so the current row can advance after a real turnaround. Coordinates stay in memory. They are not written into the saved setup (`strikeout.v1`) and they are not sent anywhere.
- Approximate location is used only when Screen is Auto, to compute sunrise and sunset. It does not use the light sensor. Same rule: memory only, not saved, not sent.
- If Auto is off and Screen is Day or Night, the app does not ask for location.
- There is no account, no analytics, no advertising ID, no crash vendor, and no payment form. Purchases are Google Play's, and the app does not receive card data.
- The app fetches its own pages, `version.json`, and the privacy text. Those requests carry no field numbers and no coordinates.
- Header names (optional, such as a first name on a machine) stay on the phone unless the operator uses the phone's share sheet or a file.

Because the answer is No, the follow-ups about encryption in transit and a deletion request do not apply to data you hold. You do not hold any. Reset everything in Settings clears the on-phone setup. There is no server copy.

Do not declare location as collected. Do declare the location **permission** in the separate permissions form, because the Android package requests it:

- Approximate location: yes, in the foreground, optional.
- Precise location: yes, in the foreground, optional.
- Background location: **no.** The manifest does not request background location. There is no foreground service.
- Is location required for the app to function? **No.** The line card works with a typed row if location is denied.

Notifications: the package does not request the notification permission. Strikeout Harvest never posts a notification. See `play/README.md` for why the project file mentions that permission and then removes it.

Privacy policy URL: host `play/privacy.html` after you replace CONTACT_EMAIL. Until that page is on a public URL, Play will not accept a policy that nobody can open. The in-app page already live at `https://randyscustomapps.github.io/strikeout/privacy.html` is the same location and on-device wording, without the company contact line. Use this draft once it is published. A privacy policy URL is required because the app uses location.

## Store graphics

| File | Size | Use |
| --- | --- | --- |
| `play/graphics/icon-512.png` | 512×512 PNG | High-res icon. Flat-auger combine and the STRIKEOUT / HARVEST lockup, on the app's dark brown. |
| `play/graphics/feature-graphic.png` | 1024×500 PNG | Feature graphic. |
| `play/graphics/screenshots/01-home-day.png` | 1200×2460 | Field, day. |
| `play/graphics/screenshots/02-home-night.png` | 1200×2460 | Field, night. |
| `play/graphics/screenshots/03-others.png` | 1200×2460 | Others sheet. |
| `play/graphics/screenshots/04-didnt-follow.png` | 1200×2460 | Didn't follow sheet. |
| `play/graphics/screenshots/05-settings.png` | 1200×2460 | Settings, headers. |
| `play/graphics/screenshots/06-settings-screen.png` | 1200×2220 | Settings, screen and Auto. |

Phone screenshots are 24-bit PNG, no alpha. The feature graphic is 24-bit PNG, no alpha. The icon is 32-bit PNG.

Sample field in every shot, not a blank install: Randy's header is 40 ft and he is the lead. Pat and Dana, both 40 ft, are following on the right. Joe at 35 ft 1 in didn't follow. Overlap is 6 inches. Current row is 78, numbers count up. The card reads +6 lines, nudge 7 ft 11 in right after the turn, go to 84. Auto is off in the shots so the card is not waiting on a GPS fix. Screen is Day in the day shots and Night in the night shot.
