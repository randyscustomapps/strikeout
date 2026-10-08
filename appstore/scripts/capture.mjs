/**
 * Shoot the App Store screenshots from the bundled page (the iOS copy).
 * Run after ios/scripts/sync-web.sh. Uses the Chrome already on the machine.
 *
 *   npm install --prefix /tmp/shot puppeteer-core
 *   node appstore/scripts/capture.mjs
 */
import { createRequire } from 'node:module';
import { spawn } from 'node:child_process';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(process.env.PUPPETEER_RESOLVE_FROM || '/tmp/shot/package.json');
const puppeteer = require('puppeteer-core');

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const web = path.join(root, 'ios/Strikeout/Web');
const outRoot = path.join(root, 'appstore/screenshots');
const chrome = process.env.CHROME || '/usr/local/bin/google-chrome';

const sample = {
  heads: [
    { id: 'randy', in: 480, label: 'Randy' },
    { id: 'pat', in: 480, label: 'Pat' },
    { id: 'dana', in: 480, label: 'Dana' },
    { id: 'joe', in: 421, label: 'Joe' }
  ],
  lead: 'randy',
  counts: { pat: 1, dana: 1 },
  leaveCounts: { joe: 1 },
  overlapIn: 6,
  stepIn: 1,
  mode: 'double',
  folSide: 'right',
  folSkip: true,
  cut: 'right',
  theme: 'day',
  wake: false,
  dim: false,
  lineNow: 78,
  lineDir: 'up',
  fieldAxis: 'ns',
  autoAdv: false,
  confirmFt: 100
};

const sizes = [
  { dir: 'iphone-6.9', cssW: 440, cssH: 956, pxW: 1320, pxH: 2868 },
  { dir: 'iphone-6.7', cssW: 430, cssH: 932, pxW: 1290, pxH: 2796 },
  { dir: 'iphone-6.5', cssW: 428, cssH: 926, pxW: 1284, pxH: 2778 }
];

function serve(dir) {
  const port = 8765;
  const child = spawn('python3', ['-m', 'http.server', String(port), '--bind', '127.0.0.1'], {
    cwd: dir,
    stdio: 'ignore'
  });
  return new Promise((resolve, reject) => {
    const start = Date.now();
    const ping = () => {
      fetch('http://127.0.0.1:' + port + '/index.html').then((r) => {
        if (r.ok) resolve({ port, child });
        else setTimeout(ping, 100);
      }).catch(() => {
        if (Date.now() - start > 10000) reject(new Error('server did not start'));
        else setTimeout(ping, 100);
      });
    };
    child.on('exit', (code) => reject(new Error('http.server exited ' + code)));
    setTimeout(ping, 150);
  });
}

async function shot(browser, base, size, name, theme, prepare) {
  if (process.env.ONLY && !process.env.ONLY.split(',').includes(name)) return null;
  const page = await browser.newPage();
  await page.setViewport({ width: size.cssW, height: size.cssH, deviceScaleFactor: 3 });
  await page.emulateMediaFeatures([{ name: 'prefers-reduced-motion', value: 'reduce' }]);
  const state = { ...sample, theme, heads: sample.heads.map((h) => ({ ...h })), counts: { ...sample.counts }, leaveCounts: { ...sample.leaveCounts } };
  await page.evaluateOnNewDocument((raw) => {
    localStorage.setItem('strikeout.v1', raw);
  }, JSON.stringify(state));
  page.setDefaultTimeout(20000);
  await page.goto(base, { waitUntil: 'domcontentloaded' });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForSelector('#lineGoNum');
  const go = await page.$eval('#lineGoNum', (el) => el.textContent.trim());
  const card = await page.$eval('#resultMain', (el) => el.innerText);
  if (go !== '84' || !card.includes('+6') || !card.includes('11')) {
    throw new Error(name + ' card was ' + JSON.stringify({ go, card }));
  }
  if (prepare) await prepare(page);
  await new Promise((r) => setTimeout(r, 250));
  const dir = path.join(outRoot, size.dir);
  await mkdir(dir, { recursive: true });
  const file = path.join(dir, name);
  await page.screenshot({ path: file, type: 'png' });
  await page.close();
  console.log(name, size.dir);
  return file;
}

async function scrollTo(page, scrollerSel, targetSel) {
  await page.evaluate((scrollerSel, targetSel) => {
    const sc = document.querySelector(scrollerSel);
    const el = document.querySelector(targetSel);
    const top = el.getBoundingClientRect().top - sc.getBoundingClientRect().top + sc.scrollTop;
    sc.scrollTop = Math.max(0, top - 16);
  }, scrollerSel, targetSel);
}

const server = await serve(web);
const base = `http://127.0.0.1:${server.port}/index.html`;
const browser = await puppeteer.launch({
  executablePath: chrome,
  headless: 'new',
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--hide-scrollbars', '--force-color-profile=srgb']
});

try {
  const files = [];
  for (const size of sizes) {
    files.push(await shot(browser, base, size, '01-home-day.png', 'day'));
    files.push(await shot(browser, base, size, '02-home-night.png', 'night'));
    files.push(await shot(browser, base, size, '03-following.png', 'day', async (page) => {
      await page.evaluate(() => document.getElementById('othersBtn').click());
      await page.waitForSelector('#othersSheet[open]');
    }));
    files.push(await shot(browser, base, size, '04-didnt-follow.png', 'day', async (page) => {
      await page.evaluate(() => document.getElementById('didntBtn').click());
      await page.waitForSelector('#didntSheet[open]');
    }));
    files.push(await shot(browser, base, size, '05-settings.png', 'day', async (page) => {
      await page.evaluate(() => document.getElementById('setBtn').click());
      await page.waitForSelector('#settings:not([hidden])');
    }));
    files.push(await shot(browser, base, size, '06-settings-screen.png', 'day', async (page) => {
      await page.evaluate(() => document.getElementById('setBtn').click());
      await page.waitForSelector('#settings:not([hidden])');
      await page.evaluate(() => {
        const sc = document.querySelector('#settings .ctrls');
        const el = document.getElementById('stepSeg').closest('section');
        const top = el.getBoundingClientRect().top - sc.getBoundingClientRect().top + sc.scrollTop;
        sc.scrollTop = Math.max(0, top - 8);
      });
    }));
    files.push(await shot(browser, base, size, '07-help.png', 'day', async (page) => {
      await page.evaluate(() => document.getElementById('setBtn').click());
      await page.waitForSelector('#settings:not([hidden])');
      await page.evaluate(() => document.getElementById('helpBtn').click());
      await page.waitForSelector('#helpSheet:not([hidden])');
      await scrollTo(page, '#helpSheet .ctrls', '#supportMail');
    }));
  }
  console.log(files.filter(Boolean).join('\n'));
} finally {
  await browser.close();
  server.child.kill();
}
