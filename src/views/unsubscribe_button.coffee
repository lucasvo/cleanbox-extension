define [
  'jquery'
  'underscore'
  'backbone'
  'cs!views/unsubscribe_overlay'
], ($, _, Backbone, UnsubscribeOverlay) ->
  class UnsubscribeButton extends Backbone.View
    tagName: 'a'
    className: 'T-I J-J5-Ji lS ar7 greenButtonBg unsubscribeMail'
    template: '''<%= text %>'''

    events:
      'click' : 'buttonClick'

    attributes:
      style: '-webkit-user-select: none;'
      role: 'button'
      tabindex: '0'
      'aria-expanded': 'false'
      'aria-haspopup': 'false'
      'aria-label': 'Unsubscribe'
      'data-tooltip': 'Unsubscribe from this Newsletter'

    initialize: (options) ->
      @link = options.link
      @text = "Unsubscribe"

      return @

    context: ->
      {
        text: @text
        link: @link
      }

    buttonClick: (e) ->
      @overlay= new UnsubscribeOverlay({url: @link})
      @overlay.render()
      @overlay.show()
      e.preventDefault()
      return false

    render: ->
      @$el.html(_.template(@template)(@context()))
      @$el.attr('href', @link)
      @$el.addClass(@className)
      @

    dispose: ->
      @overlay?.dispose()
      @off()
      @$el.remove()
      return

