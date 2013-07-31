require.config({
  paths: {
    text: 'libs/require/text',
    jquery: 'libs/jquery-min',
    cs: 'libs/cs',
    'coffee-script':'libs/coffee-script',
    underscore: 'libs/underscore',
    backbone: 'libs/backbone',
    mustache: 'libs/mustache'
  },
  baseUrl: '.'
});
require([
  'cs!gmailapp'
], function(GMailApp) {
  // Initialize app
  GMailApp.initialize();
});
