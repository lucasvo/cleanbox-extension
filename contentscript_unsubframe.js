var h = document.head || document.documentElement,
        mainjs = '',
        runCount = 0,
        userEmail = '';


function injectMainJS() {
  // Only inject script when RequireJS is ready AND mainjs has been loaded
  if (++runCount === 2) {
    injectMainJS = function() {
    var s = document.createElement('script');
      s.textContent = mainjs;
      h.appendChild(s);
    }
    injectMainJS();
  }
}

function loadApp() {
// set user email
document.body.setAttribute("data-cleanbox-email", userEmail);

// Load `main.js`, and change `baseUrl: '.'` to `baseUrl: baseUrl`.
var x = new XMLHttpRequest();
x.onload = function() {
  mainjs = '(function(baseUrl) {' +
    x.responseText.replace(/(["']?)baseUrl\1:\s*(?:"[^"]*"|'[^']*')\s*(,?)/, 'baseUrl: baseUrl$2') +
  '})(' + JSON.stringify(chrome.extension.getURL("/src/")) + ');';
  injectMainJS();
  x = null;
};
x.open('GET', chrome.extension.getURL('/src/unsubframe.js'));
x.send();

// Insert RequireJS
s = document.createElement('script')
s.src = chrome.extension.getURL('/src/libs/require.js');
s.onload = function() {
  // The easiest way to tell the content script which version of the extension is installed.
  injectMainJS();
};
h.appendChild(s);
}
var parseResponse;
parseResponse = function (e) {
  // Verify the message response and trigger our unsubscribe script on receiving a message
  if (e.data.cleanbox == true) {
    userEmail = e.data.email;
    loadApp();
  };
};
// Setup message handler to receive the user's gmail addres if the user is in gmail
addEventListener('message', function (e) {
  parseResponse(e);
});
// Send message to parent frame
window.onload = function() {
  if (window != top) {
    window.parent.postMessage({"cleanbox_request":true}, '*');
  };
};
