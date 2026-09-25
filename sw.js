// Strikeout offline support.
// When you publish an update: bump APP_VERSION in index.html AND "version" in version.json.
// Bump VERSION to a new cache name that includes that app version so phones drop the old cache.
// Never add version.json here — the update check must always hit the network.
const VERSION = 'strikeout-cache-1.0.27';
const CORE = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './apple-touch-icon.png',
  './fonts/barlow-latin-500.woff2',
  './fonts/barlow-latin-600.woff2',
  './fonts/barlow-latin-700.woff2',
  './fonts/big-shoulders-display-latin-700.woff2',
  './fonts/big-shoulders-display-latin-800.woff2',
  './fonts/big-shoulders-display-latin-900.woff2'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(CORE)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // The update check always goes to the network, never the cache.
  if (url.pathname.endsWith('/version.json')) return;
  // The app page: network first (so restarts pick up updates), cached copy when there's no signal.
  if (req.mode === 'navigate') {
    e.respondWith(
      fetch(req, { cache: 'no-store' })
        .then(r => { const copy = r.clone(); caches.open(VERSION).then(c => c.put('./index.html', copy)); return r; })
        .catch(() => caches.match('./index.html').then(r => r || caches.match('./')))
    );
    return;
  }
  // Icons, fonts: cache first, then network.
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(r => {
    if (r && (r.ok || r.type === 'opaque')) { const copy = r.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
    return r;
  }).catch(() => hit)));
});
