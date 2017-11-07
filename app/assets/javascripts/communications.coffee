@CommunicationsPooler =
  pool: ->
    setTimeout(@request, 5000)

  request: ->
    $.get($('#communications').data('url'), after: $('.communication_hidden')[$('.communication_hidden').length-1].value)

$ ->
  scroll_list()

  if $('#chats').length > 0
    ChatsPooler.pool()