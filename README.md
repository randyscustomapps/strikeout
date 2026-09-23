# Strikeout

Tells the lead combine how many GPS lines to skip, and how far to nudge, so the crew's return pass finishes the land flush.

## Put it on GitHub Pages (free)
1. Make a new public repo on GitHub, e.g. `strikeout`.
2. Upload every file in this folder to the repo's main branch (Add file → Upload files).
3. Repo **Settings → Pages → Build and deployment**: Source = *Deploy from a branch*, Branch = `main`, folder `/ (root)`. Save.
4. After a minute it's live at `https://<your-username>.github.io/strikeout/`. Send that link to the crew.

## Put it on the phone like an app
- **iPhone (Safari):** open the link → Share → *Add to Home Screen*.
- **Android (Chrome):** open the link → ⋮ menu → *Install app* / *Add to Home screen*.

Open it once with signal. After that it works with no cell service.

## Updating
Edit `index.html`, raise `APP_VERSION` in it, and set the same number in `version.json`. Phones show a red dot and an Update Now button in Settings. See INSTRUCTIONS.md.

## The math
- GPS line spacing = the lead's header width (no overlap set in the GPS).
- Each head's cut = header width − overlap per head.
- Following me out = Yes: room = followers' passes going out + whole crew coming back.
- Following me out = No: room = whole crew coming back (you included).
- Lines to move = room ÷ line spacing + 1 (your own pass). The remainder is the nudge, and the app picks whichever way needs the smaller nudge.
