ready = ->
  $buttons = $('#admin_print_invoices, #admin_print_labels, #admin_ship_orders, #admin_email_invoices')
  return unless $buttons.length > 0

  $('.order-row-checkbox').on "click", ->
    order_ids = $('.order-row-checkbox:checked').map ->
      $(this).val()
    .get()
    $buttons.attr "disabled", (order_ids.length == 0)
    if order_ids.length > 0
      params =
        order_ids: order_ids
      $buttons.each ->
        url = $(this).data "url"
        url = url + "?" + $.param(params)
        $(this).attr "href", url
    else
      button.attr "href", '#'


$(document).ready(ready)
