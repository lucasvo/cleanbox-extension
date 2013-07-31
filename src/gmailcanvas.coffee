###
This module runs in the top Gmail frame, and provides access to
 the canvas frame

Public methods and properties:
- insertCSS(cssText)  Inserts a stylesheet in the canvas
- document            Refers to the actual canvas
- $document           Alias for $(canvasDocument)
- $                   Alias for $document.find
- getDocument         Refreshes document reference if needed, and
                     returns the current canvasDocument
###
define ['jquery'], ($) ->
  # Gets document of the active Gmail canvas
  
  cssTexts = []
  cssLinks = []
  styleSheets = []
  gmailCanvas =
    insertCSS: (cssText) ->
      if (i = cssTexts.indexOf(cssText)) == -1
        # Add style sheet to list
        cssTexts.push cssText
        # Create style sheet
        styleSheet = $("<style>#{cssText}</style>")[0]
        styleSheets.push styleSheet
      else # Already known
        styleSheet = styleSheets[i]
      # Insert style sheet in document
      if gmailCanvas.document?.head
        gmailCanvas.document.head.appendChild(styleSheet)
      else
        gmailCanvas.ready -> gmailCanvas.document?.head.appendChild(styleSheet)
      return
    
    # Makes sure that all previously created style sheets exist.
    # This is the inverse of `removeStyleSheets`
    ensureCSS: ->
      if head = gmailCanvas.document?.head
        for styleSheet in styleSheets
          if styleSheet.parentNode isnt head
            head.appendChild(styleSheet)
      else
        gmailCanvas.ready(gmailCanvas.ensureCSS)
      return
    
    # There's not much to destroy, but we can remove the style sheets:
    removeStyleSheets: ->
      for styleSheet in styleSheets
        if styleSheet.parentNode
          styleSheet.parentNode.removeChild(styleSheet)
      styleSheets
      
    
# When Gmail loads slow, the document's body stays `<div></div>` for a while
# When this module is activated in this stage, the rendering of the dialog must be
#  deferred. Otherwise, Gmail removes the dialog once its ready to render their stuff.
# To detect whether Gmail has already created their own UIs, just check if there's any
# form element in the document (= the one containing the top search element)
  gmailCanvas.isReady = ->
    gmailCanvas.getDocument()?.forms.length > 0
  
  _readyStack = null
  gmailCanvas.ready = (func) ->
    if _isReady = gmailCanvas.isReady()
      func()
    else
      if _readyStack
        # Not ready yet, but stack exists, push method to stack
        _readyStack.push(func)
      else
        _readyStack = [func]
        # And start polling if not already done
        allowedRepeat = 4000 # Stop polling after 10 minutes. Extremely unlikely to happen, but safeguard in the case that it happens
        startedReadyPolling = setInterval ->
          if gmailCanvas.isReady()
            clearInterval(startedReadyPolling)
            startedReadyPolling = null
            # Call all stacked methods
            while func = _readyStack.shift()
              func()
          else if --allowedRepeat < 0
            console.error('gmailCanvas ready state never detected')
            clearInterval(startedReadyPolling)
            startedReadyPolling = null
        , 150
    return _isReady
      
  gmailCanvas.$ = (selector) -> @$document.find(selector)
  gmailCanvas.$document = $(document) # Placeholder to prevent errors
  gmailCanvas.document = document     # Placeholder to prevent errors
  gmailCanvas.$window = $(window)
  
  retry_attempts_left = 5
  gmailCanvas.getDocument = ->
    # Detect canvas frame
    frame = document.getElementById('canvas_frame')
    if not frame
      if document.getElementById('js_frame') or document.body?.onload
        # Case 1: Sometimes, Gmail is loaded in the document instead of an IFRAME (observed by Lucas)
        # Case 2: Loaded Compose/conversation screen in separate window (`document.body.onload`)
        doc = document
      else
        # Should not happen!
        console.log 'The document is not recognised as Gmail!'
        $ -> # $(document).ready ...
          if retry_attempts_left-- > 0
            gmailCanvas.getDocument() # Try again
      null
    else
      # The frame has (re)loaded, refresh references
      doc = frame.contentDocument
    
    # Document found. Update values and stylesheet if document has changed
    if doc
      if doc isnt gmailCanvas.document
        gmailCanvas.document = doc
        gmailCanvas.$document = $(doc)
        gmailCanvas.$window = $(doc.defaultView)
        @ensureCSS() # Add stylesheets to relevant context
      return doc
      
  gmailCanvas.getDocument()
  
  # dispose - To be used when the application is fully disposed
  gmailCanvas.dispose = ->
    gmailCanvas.removeStyleSheets()
    cssTexts = []
    cssLinks = []
    styleSheets = []
    # Remove references, to emphasize that gmailCanvas is really gone.
    # If anything did not implement dispose etc correctly, then an error will show up
    # in the console, which provides an entry point for debugging
    
    # Remove any remaining events
    gmailCanvas.$document?.off()
    gmailCanvas.$window?.off()
    
    # Void
    gmailCanvas.$document = gmailCanvas.document = gmailCanvas.$window = null
  gmailCanvas
