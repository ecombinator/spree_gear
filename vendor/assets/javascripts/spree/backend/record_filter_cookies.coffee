cookieName = ->
  $('#all_filter').data("model") + '_state_filter'

setStateFilter = (cookie_state, expiresInDays) ->
  d = new Date
  d.setTime d.getTime() + expiresInDays * 24 * 60 * 60 * 1000
  expires = 'expires=' + d.toUTCString()
  document.cookie = "#{cookieName()}=#{cookie_state};#{expires};path=/"

getCookieValue = (a) ->
  b = document.cookie.match('(^|;)\\s*' + a + '\\s*=\\s*([^;]+)')
  if b then b.pop() else ''

deleteCookie = ->
  document.cookie = "#{cookieName()}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;"

isSelectedAlready = (state) ->
  return false if getCookieValue(cookieName()) != state
  deleteCookie()
  true

ready = ->

  return unless $('#all_filter').length > 0

  stateFilter = getCookieValue(cookieName())
  $('#' + stateFilter + '_filter').addClass 'btn-primary'

  $('.btn-filter').each ->
    filter = $(this).data('filter')
    $('#' + filter + '_filter').on 'click', ->
      if !isSelectedAlready(filter)
        setStateFilter filter, 30

$(document).ready ready
