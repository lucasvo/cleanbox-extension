var h = document.head || document.documentElement,
        mainjs = '',
        runCount = 0;

function injectMainJS() {
  // Only inject script when RequireJS is ready AND mainjs has been loaded
  if (++runCount == 2) {
    injectMainJS = function() {
    var s = document.createElement('script');
      s.textContent = mainjs;
      h.appendChild(s);
    }
    injectMainJS();
  }
}

// Load `main.js`, and change `baseUrl: '.'` to `baseUrl: baseUrl`.
var x = new XMLHttpRequest();
x.onload = function() {
  mainjs = '(function(baseUrl) {' +
    x.responseText.replace(/(["']?)baseUrl\1:\s*(?:"[^"]*"|'[^']*')\s*(,?)/, 'baseUrl: baseUrl$2') +
  '})(' + JSON.stringify(chrome.extension.getURL("/src/")) + ');';
  injectMainJS();
  x = null;
};
x.open('GET', chrome.extension.getURL('/src/main.js'));
x.send();

// Insert RequireJS
s = document.createElement('script')
s.src = chrome.extension.getURL('/src/libs/require.js');
s.onload = function() {
  // The easiest way to tell the content script which version of the extension is installed.
  injectMainJS();
};
h.appendChild(s);
