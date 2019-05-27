ready = ->
  $('.admin-report.table').DataTable
    fixedHeader:
      header: true
    dom: 'Bfrtip',
    buttons: [
      'copy', 'csv', 'excel'
    ]
    scrollY:        "500px"
    scrollCollapse: true
    paging:         false

$(document).ready ready
