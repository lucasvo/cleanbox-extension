define [
  'jquery'
  'underscore'
], ($, _) ->
  class UnsubscribeApp
    initialize: ->
      @userEmail = $('body').attr('data-cleanbox-email')
      $(document).ready(@load)

    load: =>
      @scrolled = false
      $("input[type=text]").each((i, field) =>
        $field = $(field)

        if $field.val().match(/.+@.+\..+/gi)
          return
        
        if not @scrolled
          @scrolled = true
          $(document).scrollTop($field.position().top-80)

        name = $field.attr('name')
        id = field.id

        if id.match(/email/gi) or name.match(/email/gi)
          $field.val(@userEmail)
          $field.css({
            'color':'rgb(44,126,0)'
            'font-weight':'bold'
          })
      )
    
   new UnsubscribeApp
