@scroll_list = () ->
  $('#chats').animate({scrollTop: $('#chats').prop("scrollHeight")}, 500);

@ChatsPooler =
  pool: ->
    setTimeout(@request, 5000)

  request: ->
    if $('.message_hidden').length == 0
      after = 0
    else
      after = $('.message_hidden')[$('.message_hidden').length-1].value

    $.get($('#chats').data('url'), after: after)

$ ->
  scroll_list()

  if $('#chats').length > 0
    ChatsPooler.pool()