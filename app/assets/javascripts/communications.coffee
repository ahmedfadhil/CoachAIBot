@CommunicationsPooler =
  pool: ->
    setTimeout(@request, 5000)

  request: ->
    $.get($('#communications').data('url'))

$ ->
  CommunicationsPooler.pool()