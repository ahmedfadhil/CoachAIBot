@push_footer = () ->
  content_height = $("#main-container").height()
  footer = $(".footer")
  footer_position = footer.position()['top']
  console.log('content height: ' + content_height)
  console.log('footer position: ' + footer_position)

  if (content_height > footer_position)
    console.log('footer pushed on the bottom')
    footer.css("position", "absolute")
    footer.css("bottom", "0")
    footer.css("width", "100%")

$ ->
  push_footer()
  $(".close").click (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()
