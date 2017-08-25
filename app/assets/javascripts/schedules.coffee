@byDate = (element) ->
  div_date = document.getElementById('weekly-schedules-by-date')
  div_day = document.getElementById('weekly-schedules-by-day')

  rb_date = document.getElementById('specify_date')
  rb_day = document.getElementById('specify_day')

  rb_date.checked = true
  rb_day.checked = false

  div_date.style.display = 'block'
  div_day.style.display = 'none'

@byDay = (element) ->
  div_date = document.getElementById('weekly-schedules-by-date')
  div_day = document.getElementById('weekly-schedules-by-day')
  rb_date = document.getElementById('specify_date')
  rb_day = document.getElementById('specify_day')

  rb_date.checked = false
  rb_day.checked = true

  div_date.style.display = 'none'
  div_day.style.display = 'block'

$ ->
  $("input[data-by-date=true]").change (e) ->
    e.preventDefault()
    byDate(this)

$ ->
  $("input[data-by-day=true]").change (e) ->
    e.preventDefault()
    byDay(this)
