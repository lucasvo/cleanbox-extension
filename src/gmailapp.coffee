define [
  'jquery'
  'underscore'
  'cs!gmailcanvas'
  'cs!views/unsubscribe_button'
  'cs!views/toolbar_area'
  'cs!linkfinder'
  'text!css/style.css'
], ($, _, gmailCanvas, UnsubscribeButton, ToolbarArea, linkFinder, stylesheet) ->
  class Application
    initialize: ->
      gmailCanvas.ready(=> @gmailReady())
      do lookForGLOBALS = =>
        GMAIL_GLOBALS = if window.GLOBALS then GLOBALS else if opener?.GLOBALS then opener.GLOBALS

        # Grab the email address from GLOBALS[10]
        # window.opener.GLOBALS if a new Compose instance is opened
        @emailAddress = GMAIL_GLOBALS?[10]
        @requestToken = GMAIL_GLOBALS?[9]
        @sessionNumber = document.location.href.match(/\/u\/\d\//)[0][3]

        if not @emailAddress
          if document.readyState == 'complete'
            console.log('CleanBox: Unable to detect email address')
          else
            # Check again
            setTimeout(lookForGLOBALS, 1)
          return
        
    gmailReady: ->
      setTimeout(@onUrlChange, 3000)
      $(window).on('hashchange', @onUrlChange)
      gmailCanvas.insertCSS(stylesheet)
      @onUrlChange()
      @registerMessageHandler()

    onUrlChange: =>
      if @toolbar? then @disposeToolbar()
      # Check if we are in a conversation view
      if @getConversationIDfromURL()
        # Search for unsubscribe Link
        cb = (elem_subsc) =>
          if elem_subsc
            @renderToolbarArea(elem_subsc)
        elem_subsc = linkFinder.find(cb, [@sessionNumber, @requestToken, @getConversationIDfromURL()])

    renderToolbarArea: (link) ->
      @toolbar = new ToolbarArea({link: link}).render()

    disposeToolbar: () ->
      @toolbar?.dispose()
      delete @toolbar

    getConversationIDfromURL:  =>
      conversationid = /\b[a-f0-9]{16}$/.exec(location.hash)
      conversationid && conversationid[0]

    getUnsubscribeFrame: =>
      gmailCanvas.$("#unsuboverlayframe")[0]
      

    registerMessageHandler: =>
      addEventListener('message', (e) =>
        @messageHandler(e)
      )

    messagePayload: () =>
      {
        cleanbox: true
        email: @emailAddress
      }

    messageHandler: (e) =>
      if e.data.cleanbox_request
        frame = @getUnsubscribeFrame()
        frame.contentWindow.postMessage(@messagePayload(), '*')

    dispose: ->
      @disposeToolbar()
      return

  new Application
