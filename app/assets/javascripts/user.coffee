@paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

@default_tab = () ->
  document.getElementById('overview-user').style.background = '#F0F8FF'
  document.getElementById('all_plans_users').style.background = '#F0F8FF'


$ ->
  default_tab()

  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
