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
    simple_link_text: /(abmelden|subscription preferences|safeunsubscribe|désabonner|opt_out|optout|unsubscribe|email preferences|notification settings)/i
    checkLink: (link) ->
      unsubText = @simple_link_text.exec($(link).text())
      if unsubText then return link
      unsub = @simple_link_content.exec($(link).attr('href'))
      if unsub then return link
         
    find: () ->
      links = gmailCanvas.$(".ads a")
# ### Direct Match
# Reverse loop is a performance tweak because emails are more likely to contain unsubscribe links at the end of emails
      i = 1
      while i < links.length
        link = links[links.length-i]
        i++
        res = @checkLink(link)
        if res then return $(link).attr('href')
      res = @proximitySearch()
      if res then return res.attr('href')

# ### Proximity Search
    proxLinkFilter: /click/i
    proxTextFilter: /unsubscribe/i
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
          console.log 'skipping'
          continue
        processedParents.push(parent)
  
        for node in parent.contents()
          if node.nodeType == 1 and @proxLinkFilter.exec($(node).text())
            console.log $(node).attr("href"), @proxLinkExclusion.exec($(node).attr("href"))
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

  new LinkFinder

