@check_daily_blank = () ->
  any_blank_fields = '' in (field.value for field in $(".daily-input"))
  if any_blank_fields
    $("#daily-submit").prop('disabled', true)
  else
    $("#daily-submit").prop('disabled', false)

@show_hide_hour = () ->
  btn = document.getElementById("add-hour-btn")
  console.log(btn.val)
  divs = document.getElementsByClassName("time-sched")
  for div in divs
    display = window.getComputedStyle(div).display;
    if display == 'none'
      btn.innerHTML = '<i class="material-icons">alarm_off</i> &nbsp Togli Ora'
      div.style.display = 'block'
    else
      btn.innerHTML = '<i class="material-icons">alarm_add</i> &nbsp Aggiungi Ora'
      div.style.display = 'none'


$ ->
  check_daily_blank()

  $(".daily-input").change (e) ->
    e.preventDefault()
    check_daily_blank()

  $(".monthly-schedule-date").datepicker(
    dateFormat: 'dd/mm/yy'
    onSelect: (dateText) ->
      $(this).parent().addClass("is-dirty")
  )

  $(".add-hour").click (e) ->
    e.preventDefault()
    show_hide_hour()



