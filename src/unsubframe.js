require.config({
  paths: {
    jquery: 'libs/jquery-min',
    cs: 'libs/cs',
    'coffee-script':'libs/coffee-script',
    underscore: 'libs/underscore',
    backbone: 'libs/backbone',
  },
  baseUrl: '.'
});
require([
  'cs!unsubscribe_page'
], function(UnsubscribePage) {

  UnsubscribePage.initialize();

});

