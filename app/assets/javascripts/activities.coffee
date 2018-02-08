@showNewCategoryInput = (element) ->
  div = document.getElementById('new-category-input')
  txtArea = document.getElementById('activity-category')
  div.style.display = 'block'

@hideNewCategoryInput = (element) ->
  div = document.getElementById('new-category-input')
  div.style.display = 'none'
  txtArea = document.getElementById('activity_category')
  txtArea.value = element.value

$ ->
  $("input[data-other-category=true]").change (e) ->
    e.preventDefault()
    showNewCategoryInput(this)

  $("input[data-other-category=false]").change (e) ->
    e.preventDefault()
    hideNewCategoryInput(this)

  $("#activities-all").css("backgroundColor", '#757575')