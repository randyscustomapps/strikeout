/* Strikeout Harvest iOS shell.
   Loaded only from the copy of the app inside the iOS bundle.
   The site at the repo root is not this file. */
(function () {
  window.STRIKEOUT_IOS = true;
  window.STRIKEOUT_PWA = false;
  document.documentElement.setAttribute('data-ios', '');

  var style = document.createElement('style');
  style.textContent = [
    'html[data-ios] body{padding-left:max(12px,env(safe-area-inset-left,0px));padding-right:max(12px,env(safe-area-inset-right,0px))}',
    'html[data-ios] .note,html[data-ios] .play-note,html[data-ios] .play-status{font-size:calc(0.95rem * var(--ios-type, 1))}',
    'html[data-ios] .play-price{font-size:calc(1.55rem * var(--ios-type, 1))}',
    'html[data-ios] .play-note a{color:inherit;font-weight:700}'
  ].join('');
  document.documentElement.appendChild(style);

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

  var held = false;
  function hold() {
    if (window.STRIKEOUT_SHOT) return;
    held = true;
    var g = document.getElementById('playGate');
    if (g) g.hidden = false;
    var app = document.querySelector('.app');
    if (app) app.setAttribute('inert', '');
  }
  function allow() {
    var g = document.getElementById('playGate');
    if (g) g.hidden = true;
    var app = document.querySelector('.app');
    if (app) app.removeAttribute('inert');
    if (held && typeof resumeAuto === 'function') {
      held = false;
      resumeAuto();
    }
  }
  function trialTitle(trial) {
    if (trial === '3 days') return '3-day free trial';
    return trial ? trial + ' free' : '3-day free trial';
  }
  function dress(state) {
    state = state || {};
    var title = document.getElementById('playTitle');
    var price = document.getElementById('playPrice');
    var note = document.getElementById('playNote');
    var status = document.getElementById('playStatus');
    var sub = document.getElementById('playSub');
    var rest = document.getElementById('playRestore');
    var manage = document.getElementById('iosManage');
    var amount = state.price || '$24.99 CAD';
    var every = state.periodPhrase || 'a year';
    var trial = state.trial || '3 days';
    var renew = 'It renews automatically until you cancel. Payment is charged to your Apple ID at confirmation, and again within 24 hours before each renewal. Cancel anytime in Settings, then Apple ID, then Subscriptions.';
    var eligible = state.eligible !== false && !!trial;
    if (title) title.textContent = eligible ? trialTitle(trial) : 'Subscribe';
    if (price) price.textContent = eligible ? ('Then ' + amount + ' ' + every + '.') : (amount + ' ' + every + '.');
    if (note) {
      note.textContent = eligible
        ? ('New subscribers get a ' + trial + ' free trial, then ' + amount + ' ' + every + '. ' + renew)
        : ('The free trial is for new subscribers. ' + amount + ' ' + every + '. ' + renew);
    }
    if (status) status.textContent = state.message || '';
    var busy = state.phase === 'checking';
    if (sub) {
      sub.disabled = !!busy;
      sub.textContent = eligible ? 'Start free trial' : 'Subscribe';
    }
    if (rest) rest.disabled = !!busy;
    if (manage) manage.disabled = false;
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
    receiveFile: function (text) { deliverText(text); },
    setTypeScale: function (n) {
      var scale = Number(n);
      if (!scale || scale < 0.8) scale = 1;
      if (scale > 1.32) scale = 1.32;
      document.documentElement.style.setProperty('--ios-type', String(scale));
    },
    onStore: function (state) {
      if (window.STRIKEOUT_SHOT) return;
      if (state && state.phase === 'entitled') {
        allow();
        return;
      }
      if (state && state.phase === 'checking' && window.__strikeoutEntitled) return;
      hold();
      dress(state);
    }
  };

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
    if (window.STRIKEOUT_SHOT) return;
    if (chk && !document.getElementById('iosManageSettings')) {
      var manageRow = document.createElement('button');
      manageRow.className = 'chkbtn';
      manageRow.id = 'iosManageSettings';
      manageRow.type = 'button';
      manageRow.textContent = 'Manage subscription';
      manageRow.addEventListener('click', function () { post({ action: 'storeManage' }); });
      chk.insertAdjacentElement('afterend', manageRow);
    }

    var cap = document.getElementById('exportHeadsCap');
    if (cap) cap.textContent = 'Opens the iPhone share sheet with the header file';

    document.querySelectorAll('#helpSheet .note').forEach(function (p) {
      if (p.textContent.indexOf('Website Settings') === -1 && p.textContent.indexOf('Add to Home') === -1) return;
      p.innerHTML = 'If location is denied, Auto turns off and the typed row still works. Choose <b>Allow While Using App</b> the first time iPhone asks. The App Store app remembers that choice. Location stays on this phone and is not uploaded.';
    });

    var sub = document.getElementById('playSub');
    var rest = document.getElementById('playRestore');
    var manage = document.getElementById('iosManage');
    if (sub && !sub.dataset.ios) {
      sub.dataset.ios = '1';
      sub.addEventListener('click', function () { post({ action: 'storePurchase' }); });
    }
    if (rest && !rest.dataset.ios) {
      rest.dataset.ios = '1';
      rest.addEventListener('click', function () { post({ action: 'storeRestore' }); });
    }
    if (manage && !manage.dataset.ios) {
      manage.dataset.ios = '1';
      manage.addEventListener('click', function () { post({ action: 'storeManage' }); });
    }
    if (!window.__strikeoutEntitled) hold();
    if (bridge()) post({ action: 'storeRefresh' });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', adaptPage);
  else adaptPage();
})();
