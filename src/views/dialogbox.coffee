# # Dialog
# ## Example
#     dialog = new DialogBoxView({title: 'Dummy'})
#     dialog.render()  # The overlay is displayed, and the dialog is displayed (but not visible)
#     dialog.show()    # Displays the dialog with a fade-in effect
# This default class does not display any message or controls.
# The user can close the dialog by pressing `ESC` or clicking the cross
#
# To determine whether a dialog is visible or not, use `@$el.is(':visible')`
#
# Do NOT override render, but _render() instead. `render` contains a part which
#  manages the visibility of the dialog before Gmail is rendered.
# Similarly, do not override `show` and `hide`, but `_show` and `_hide`
#
# For examples, see views/session/openpopup.coffee and views/taskeditdialog.coffee
define [
  'jquery',
  'underscore',
  'backbone',
  'cs!gmailcanvas',
], ($, _, Backbone, gmailCanvas) ->
  class DialogBoxView extends Backbone.View
    tagName:"div"
    className: 'dBcT Kj-JD unsubscribeOverlay'
    attributes: { role: 'dialog' }

# The template renders the parts that stay the same, the container, the close button
# and submit buttons. It should not be overwritten by a subclass.
# Inside of if there's a `div.dBc` which contains the actual content, rendered with
# `renderInner` by default with the same `context` as the outer template. You can
# either overwrite the renderInner method or just the innerTemplate string and the
# context method
# NOTE: This template is based on Gmails dialog template. It's recommended to stick to
# it, so that the dialog matches the user's style preference.
    template: '''
    <div class="Kj-JD-K7 Kj-JD-K7-GIHV4">
      <span class="Kj-JD-K7-K0"><%= title %></span>
      <span class="Kj-JD-K7-Jq cDb"></span>
    </div>
    <div class="Kj-JD-Jz dBc"></div>
    <div class="stActionButtons"></div>
    '''

# To be implemented by subclass

    initialize: ->
      # @title must be implemented by a subclass
      @title = @options.title
    innerTemplate: ''# To be implemented by subclass
    controlsTemplate: ''# To be implemented by subclass
    # `<button name="key" class="tm-key">caption</button>`
    # Replace `key` with a suitable name. GMail uses ok, cancel, yes, no, save, continue
    # Although it's not forbidden to use other names, it would be nice to stick to these
    # naming "conventions"
    # Class name for active Button: .T-I-atl
    # class="T-I J-J5-Ji Zx acL T-I-atl L3"
    #
    # To be extended by subclass:
    #
    #     context: ->
    #       context = _.extend super(), {
    #         title: 'new title etc'
    #       }
    #       context.example = 'another way'
    #       return context
    context: ->
      context = {}
      if @title
        context.title = @title
      return context

    # Triggered when the close button is clicked or when ESC is pressed.
    # Override in subclass if a different behaviour is desired.
    closeButtonHandler: ->
      @hide()

# To properly position the dialog, we have to update the values
# so that it's centered.
    resize: =>
      # Do NOT override the value of margin, top and left.
      # It's used to automatically center the dialog.
      # At least the upper-left corner of the box must be visible in the document's view
      dialogHeight = @$el.outerHeight(false)
      dialogWidth = @$el.outerWidth(false)
      winHeight = gmailCanvas.$window.height()
      winWidth = gmailCanvas.$window.width()
      @$el.css
        'margin-top': -(if dialogHeight > winHeight then winHeight else dialogHeight) / 2 + 'px'
        'margin-left': -(if dialogWidth > winWidth then winWidth else dialogWidth) / 2 + 'px'
      @

    renderInner: (context) ->
      return _.template(@innerTemplate)(context)

    renderControls: (context) ->
      return _.template(@controlsTemplate)(context)

    render: ->
      gmailCanvas.$window.off('resize', @resize)
      gmailCanvas.$window.on('resize', @resize)

      context = @context()
      # Render main dialog
      template = _.template(@template)(context)
      @$el.html(template)
      # Render contents
      @$('div.dBc').html(@renderInner(context))
      @$('div.stActionButtons').html(@renderControls(context))
      # Add default behaviour to close button (upperright corner) event when not defined
      @$('.cDb').on('click', => @closeButtonHandler())
      @delegateEvents()
      @trigger("rendered")
      @

    show: ->
      if @_deferredRender # Handle deferred dialog
        @_deferredRenderVisible = true
        return @

      # Remove previous dialog of same instance
      if @$container
        @$container.remove()

      # Insert background layer
      gmailCanvas.ensureCSS()
      $body = gmailCanvas.$('body')
      @$container = $('<div class="dBbg">').appendTo($body)
      @$container.css({
        'overflow': 'auto'
      })
      @$container.click(@hide)
      @$el.appendTo(@$container)
      @$container.appendTo($body)

      # Calculate and set correct position
      @resize()

      # Avoid double event handler, so remove old one before adding new one
      # Adding event class cid so that `@$el.off()` does not remove the wrong events (from a different instance)
      gmailCanvas.$document.off('keyup.' + @cid, @_escEventHandler).on('keyup.' + @cid, @_escEventHandler)
      @_show()

    _escEventHandler: (ev) =>
      if ev.which == 27
        ev.stopPropagation()
        ev.preventDefault()
        @closeButtonHandler()

    # Show the dialog box
    _show: ->
      @$el.show()
      @trigger("show")
      @

    hide: =>
      if @_deferredRender # Handle deferred dialog
        clearInterval(@_poller) # Cancel deferred dialog
        delete @_deferredRenderVisible
        return @
      @_hide()
      @dispose()

    # Remove the dialog box
    _hide: ->
      @$el.remove()
      @$container.remove()
      @trigger("hide")
      @

    dispose: ->
      clearInterval(@_poller)
      # Remove ESC event handler
      gmailCanvas.$document?.off('keydown.' + @cid, @_escEventHandler)
      @$el.remove()
      @$container?.remove()
      gmailCanvas.$window?.off('resize', @resize)
      delete @options
      @trigger('disposed')
      @off()
  DialogBoxView
