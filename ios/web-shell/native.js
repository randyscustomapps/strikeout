/* Strikeout Harvest iOS shell.
   Loaded only from the copy of the app inside the iOS bundle.
   The site at the repo root is not this file. */
(function () {
  window.STRIKEOUT_IOS = true;
  window.STRIKEOUT_PWA = false;

  function bridge() {
    var w = window.webkit;
    return w && w.messageHandlers && w.messageHandlers.strikeout;
  }
  function post(msg) {
    var b = bridge();
    if (b) b.postMessage(msg);
  }

  var seq = 0;
  var pending = {};
  function call(action, extra) {
    return new Promise(function (resolve, reject) {
      var b = bridge();
      if (!b) {
        reject(new Error('no-bridge'));
        return;
      }
      var id = ++seq;
      pending[id] = { resolve: resolve, reject: reject };
      var msg = { action: action, id: id };
      if (extra) {
        for (var k in extra) {
          if (Object.prototype.hasOwnProperty.call(extra, k)) msg[k] = extra[k];
        }
      }
      b.postMessage(msg);
    });
  }

  var fileQueue = [];
  function deliverText(text) {
    if (!text) return;
    var input = document.getElementById('importFile');
    if (!input || document.readyState === 'loading') {
      fileQueue.push(text);
      return;
    }
    var file = new File([text], 'strikeout-headers.json', { type: 'application/json' });
    var dt = new DataTransfer();
    dt.items.add(file);
    input.files = dt.files;
    input.dispatchEvent(new Event('change'));
  }

  window.strikeoutNative = {
    get available() { return !!bridge(); },
    _done: function (id, ok, value) {
      var p = pending[id];
      if (!p) return;
      delete pending[id];
      if (!ok) {
        var err = new Error('cancel');
        err.name = 'AbortError';
        p.reject(err);
      } else {
        p.resolve(value == null ? true : value);
      }
    },
    shareLink: function (url) { return call('shareLink', { url: url }); },
    shareFile: function (name, text) { return call('shareFile', { filename: name, text: text }); },
    pickHeaderFile: function () { return call('pickHeaderFile', {}); },
    receiveFile: function (text) { deliverText(text); }
  };

  // The bundle is the app. Drop the web-app manifest so nothing offers
  // Add to Home Screen, and ignore a browser install prompt if one fires.
  document.querySelectorAll('link[rel="manifest"]').forEach(function (n) { n.remove(); });
  window.addEventListener('beforeinstallprompt', function (e) { e.preventDefault(); });

  if (bridge()) {
    navigator.wakeLock = {
      request: function () {
        post({ action: 'keepAwake', on: true });
        return Promise.resolve({
          released: false,
          addEventListener: function () {},
          removeEventListener: function () {},
          release: function () {
            this.released = true;
            post({ action: 'keepAwake', on: false });
            return Promise.resolve();
          }
        });
      }
    };
    navigator.vibrate = function () {
      post({ action: 'haptic', style: 'medium' });
      return true;
    };
    document.addEventListener('pointerdown', function (e) {
      var t = e.target;
      if (!t || !t.closest) return;
      var b = t.closest('button');
      if (!b || b.disabled) return;
      post({ action: 'haptic', style: 'light' });
    }, true);

    function pushBar() {
      var m = document.querySelector('meta[name="theme-color"]');
      if (!m) return;
      post({ action: 'statusBar', color: m.getAttribute('content') || '' });
    }
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta && window.MutationObserver) {
      new MutationObserver(pushBar).observe(meta, { attributes: true, attributeFilter: ['content'] });
    }
    document.addEventListener('DOMContentLoaded', pushBar);
  }

  function adaptPage() {
    fileQueue.splice(0).forEach(deliverText);

    var st = document.getElementById('verSt');
    if (st) st.textContent = 'App Store app. Updates come from the App Store.';
    var chk = document.getElementById('chkBtn');
    if (chk) chk.hidden = true;
    var dot = document.getElementById('updDot');
    if (dot) dot.hidden = true;

    var cap = document.getElementById('exportHeadsCap');
    if (cap) cap.textContent = 'Opens the iPhone share sheet with the header file';

    document.querySelectorAll('#helpSheet .note').forEach(function (p) {
      if (p.textContent.indexOf('Website Settings') === -1 && p.textContent.indexOf('Add to Home') === -1) return;
      p.innerHTML = 'If location is denied, Auto turns off and the typed row still works. Choose <b>Allow While Using App</b> the first time iPhone asks. The App Store app remembers that choice. Location stays on this phone and is not uploaded.';
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', adaptPage);
  else adaptPage();
})();
