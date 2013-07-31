define [
  'jquery'
  'underscore'
  'backbone'
  'cs!views/dialogbox'
], ($, _, Backbone, DialogBox) ->
  class UnsubscribeOverlay extends DialogBox
    title: "Unsubscribe from Newletter"
    initialize: (options) ->
      @unsubscribeLink = options.url
      return

    context: ->
      context = {
        title: 'Unsubscribe from Newsletter' #<p class="subtitle">We try to make it as easy as possible for you, filling in your email address below.</p>'
        link: @unsubscribeLink
      }
      console.log context
      return context

    innerTemplate: '''
      <iframe src="<%= link %>" id="unsuboverlayframe"></iframe>
     
     '''
  UnsubscribeOverlay

