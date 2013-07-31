define [
  'jquery'
  'underscore'
  'backbone'
  'cs!views/dialogbox'
  'cs!views/unsubscribe_button'
], ($, _, Backbone, DialogBox, UnsubscribeButton) ->
  class InfoDialogBox extends DialogBox
    title: "Reduce information overload and get rid of newsletters you never read."
    initialize: (options) ->
      return
    innerTemplate: '''
      <p>SpringCleaning locates unsubscribe links hidden in all those newsletters that 
      you signed up years ago but never read and adds a button to GMails interface.</p>

      <h3>Missing Unsubscribe Button or incorrect one?</h3>
      <p>We do our best to locate unsubscribe links as accurately as possible. But still, 
      sometimes we might get it wrong.</p>
      <p>We rely on your help with fixing these issues. If you received a newsletter that we haven't 
      discovered correctly, <a href="mailto:hello@springcleaning.com">let us know</a>. Or you can also 
      just forward us the newsletter at: <a href="mailto:hello@springcleaning.com">hello@springcleaning.com</a>
      </p>
    '''

  class ToolbarAreaView extends Backbone.View
    tagName: 'div'
    className: 'J-J5-Ji'
    template: '''
    <a class="unsubscribeButton"></a>
    <a class="aboutButton" href="#">?<!--❀--></a>  
    '''

    initialize: (options) ->
      @link = options.link
      @button = new UnsubscribeButton({link: @link})


    events: {
      "click .aboutButton": "openInfoDialog"
      }
    context: ->
      {}

    render: ->
      if @inDOM
        return @
      @$el.html(_.template(@template)(@context()))
      @assign({
        '.unsubscribeButton': this.button
      })
      
      parent = $('.aeH > .G-atb.D.E > .iH > div > .G-Ni.J-J5-Ji:nth-child(3)')
      parent.after(@$el)
      @inDOM = true
      return @

    assign : (selector, view) ->
      if !selector then return
      if _.isObject(selector) then selectors = selector
      else
        selectors = {}
        selectors[selector] = view

      _.each(selectors, (view, selector) =>
          view.setElement(@$(selector)).render()
      )

    openInfoDialog: () ->
      @infoDialog = new InfoDialogBox()
      @infoDialog.render()
      @infoDialog.show()
      return false

    dispose: ->
      @inDOM = false
      delete @inDOM
      if @infoDialog
        @infoDialog.dispose()
        delete @infoDialog
      @off()
      @$el.remove()


