@scroll_list = () ->
  console.log($('#chats li').last())
  #$('#chats').animate({ scrollTop: $('#chats').offset().top }, "slow")
  $('#chats').animate({scrollTop: $('#chats').prop("scrollHeight")}, 500);

$ ->
  scroll_list()