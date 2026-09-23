# Strikeout: setup instructions (for Claude, Grok, or a person)

Strikeout is a finished, installable web app (PWA) for phones. It is plain HTML with no build step,
no framework and no server code. **Do not rewrite, reformat or "improve" the files.** Upload them exactly as they are.

## Files (all go in the root of the repo)
| File | What it is |
|---|---|
| `index.html` | The whole app (HTML, CSS and JS in one file) |
| `manifest.webmanifest` | Makes it installable ("Add to Home Screen") |
| `sw.js` | Service worker, so it works offline |
| `fonts/` | Self-hosted Barlow and Big Shoulders Display (SIL Open Font License) |
| `version.json` | Current version number. The app checks this to show "Update available" |
| `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` | Home-screen icons |
| `README.md` | Short readme |
| `INSTRUCTIONS.md` | This file |

## Task 1: Put it on GitHub Pages
1. Create a new **public** GitHub repository named `strikeout` (any name works).
2. Upload **every file above** to the root of the `main` branch. No subfolder. Keep the filenames exactly as they are.
3. In the repo go to **Settings → Pages**, then set Source = "Deploy from a branch", Branch = `main`, Folder = `/ (root)`, and click Save.
4. Wait 1–2 minutes. The app is live at `https://<github-username>.github.io/strikeout/`.
5. Check it: open that URL. You should see "STRIKEOUT" with a big "+6 LINES" card. Then open `.../strikeout/version.json` and it should show `"version": "1.0.0"`.

It **must** be served over https (GitHub Pages is), or offline mode and updates won't work.

## Task 2: Install on a phone
- **iPhone:** open the URL in **Safari** (not Chrome) → Share button → **Add to Home Screen** → Add.
- **Android:** open the URL in **Chrome** → ⋮ menu → **Install app** (or "Add to Home screen").
- Open it once from the new icon while you have signal. After that it works with **no signal**.
- Settings (header sizes, crew counts, overlap, day/night) are saved on the phone and survive restarts.
  They're only lost if the icon is deleted or the browser's website data is cleared.

## Task 3: Push an update later
When changing anything in `index.html`:
1. Make the change in `index.html`.
2. In `index.html`, find `const APP_VERSION='1.0.0';` and raise the number, e.g. `'1.0.1'`.
3. In `version.json`, set `"version"` to **the same number**, e.g. `"1.0.1"`.
4. In `sw.js`, set `VERSION` to a new cache name that includes that same version, e.g. `'strikeout-cache-1.0.1'`. Do not add `version.json` to the cache list.
5. Commit to `main`. GitHub Pages redeploys in about a minute.

What users see: next time the app is opened or brought back to the screen, a **pulsing red dot** shows on the
settings (gear) button. In Settings, under **App version**, there's a red **UPDATE NOW** button. Tapping it
clears the old cached copy and reloads the new version. The dot goes away when the version inside `index.html`
matches `version.json`, so **the two numbers must match** or the dot will never clear.

Most of the time a normal restart with signal already loads the new version, because the app checks the network
first. The Update Now button is the sure-fire way.

## Rules for an AI editing this
- Keep the app in the single `index.html`. Font files belong in `fonts/`. Don't add a build tool.
- Don't change the saved-settings key `strikeout.v1` in `index.html`, or everyone's saved settings will reset.
- Always bump `APP_VERSION`, `version.json`, and the `VERSION` cache name in `sw.js` together (Task 3).
- Don't cache `version.json` in `sw.js`. It must always come from the network.
