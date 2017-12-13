@CommunicationsPooler =
  pool: ->
    setTimeout(@request, 30000)

  request: ->
    after = -1
    if $('.communication_hidden').length > 0
      after = $('.communication_hidden')[$('.communication_hidden').length-1].value

    $.get($('#communications').data('url'), after: after)

$ ->
  CommunicationsPooler.request()
  CommunicationsPooler.pool()
  $('.list-group').paginathing({
    perPage: 5,
    # Limites your pagination number -> false or number
    limitPagination: false,
    # Pagination controls
    prevNext: true,
    firstLast: true,
    prevText: '&laquo;',
    nextText: '&raquo;',
    firstText: 'First',
    lastText: 'Last',
    # containerClass: 'pagination-container',
    ulClass: 'pagination',
    liClass: 'page',
    disabledClass: 'disabled',
    })
