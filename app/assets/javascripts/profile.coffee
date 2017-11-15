$ ->
  $(".close").click (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()