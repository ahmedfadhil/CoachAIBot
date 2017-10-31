@scroll_list = () ->
  $('#chats').animate({scrollTop: $('#chats').prop("scrollHeight")}, 500);

@ChatsPooler =
  pool: ->
    setTimeout(@request, 5000)
    console.log 'wewewe'

  request: ->
    $.get($('#chats').data('url'), after: $('.message_hidden')[$('.message_hidden').length-1].value)

$ ->
  scroll_list()

  if $('#chats').length > 0
    ChatsPooler.pool()