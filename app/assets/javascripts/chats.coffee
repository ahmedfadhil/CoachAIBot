@scroll_list = () ->
  $('#chats').animate({scrollTop: $('#chats').prop("scrollHeight")}, 500);

$ ->
  scroll_list()