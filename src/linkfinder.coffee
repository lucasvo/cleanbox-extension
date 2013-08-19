# Link Matcher
define [
  'jquery'
  'underscore'
  'cs!gmailcanvas'
], ($, _, gmailCanvas) ->
  class LinkFinder
    constructor: () ->
      @

# Simple Link Matcher
# If the link contains any of the following strings, return a match
    simple_link_content: /(abmelden|subscription preferences|safeunsubscribe|désabonner|opt_out|optout|unsubscribe|email preferences|notification settings)/i
    simple_link_text: /(abmelden|subscription preferences|safeunsubscribe|désabonner|opt_out|optout|unsubscribe|email preferences|notification settings|stop receive|no longer wish to receive)/i

    checkLink: (link) ->
      unsubText = @simple_link_text.exec($(link).text())
      if unsubText then return link

      unsub = @simple_link_content.exec($(link).attr('href'))
      if unsub then return link
         
    find: (cb, req_info) ->
      links = gmailCanvas.$(".ads a")
# ### Direct Match
# Reverse loop is a performance tweak because emails are more likely to contain unsubscribe links at the end of emails
      i = 1
      while i < links.length
        link = links[links.length-i]
        i++
        res = @checkLink(link)
        if res then return cb($(link).attr('href'))

      # TODO: move cb into func
      res = @proximitySearch()
      if res then return cb(res.attr('href'))

      res = @findUnsubscribeHeaders(cb, req_info)

# ### Proximity Search
    proxLinkFilter: /click/i
    proxTextFilter: /(unsubscribe|stop receive|no longer wish to receive|if you don't wish to receive these messages|like to be removed from)/i
    proxLinkExclusion: /mailto/i

    proximitySearch: () ->
      processedParents = []
      links = gmailCanvas.$(".ads a")
      i = 1
      while i < links.length
        link = $(links[links.length-i])
        i++

        prev_text = ""
        prev_link_match = false


# We try to avoid parsing one parent more than once
        parent = link.parent()
        if parent in processedParents
          continue
        processedParents.push(parent)
  
        for node in parent.contents()
          if node.nodeType == 1 and @proxLinkFilter.exec($(node).text())
            prev_link_match = true

            if @proxTextFilter.exec(prev_text)
                return $(node)

          if node.nodeType == 3
            prev_text = $(node).text()
            if prev_link_match and @proxTextFilter.exec(prev_text)
                return $(node)
            prev_link_match = false
          prev_node = node
      return null

# ### List Header Search
    findUnsubscribeHeaders: (cb, req_info) ->
      $.get("https://mail.google.com/mail/u/#{req_info[0]}/?ui=2&ik=#{req_info[1]}&view=om&th=#{req_info[2]}", (text) =>
        @parseRawMessage(text, cb)
      )

    parseRawMessage: (text, cb) ->
      header = /List-Unsubscribe:.*\Z/.exec(text)
      if header
        link = /<( |)http(|s):\/\/.*>/.exec(header)?[0]
        if link
          cb(link.substr(1,link.length-2))

  new LinkFinder

