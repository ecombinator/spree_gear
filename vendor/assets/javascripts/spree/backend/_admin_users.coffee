ready = ->
  $('a.popover-image[rel=popover]').popover
    html: true
    trigger: 'hover'
    content: ->
      '<img src="' + $(this).data('img') + '" />'
  $('[data-toggle="tooltip"]').tooltip()

$(document).ready ready
