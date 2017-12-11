@push_footer = () ->
  console.log('IN')
  content_height = $("#main-container").height()
  footer = $(".footer")
  footer_position = footer.position()['top']
  console.log(content_height)
  console.log(footer_position)

  if (content_height > footer_position)
    footer.css("position", "absolute")
    footer.css("bottom", "0")
    footer.css("width", "100%")

$ ->
  push_footer()
  $(".close").click (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()
