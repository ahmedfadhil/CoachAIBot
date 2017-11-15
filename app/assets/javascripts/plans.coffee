$ ->
  from_day = $(".plan_from_day")
  to_day = $(".plan_to_day")

  from_day.datepicker(
    format: 'dd/mm/yy'
  ).on('changeDate', () ->
    from_day.parent().addClass('is-focused')
  )

  to_day.datepicker(
    format: 'dd/mm/yy'
  ).on('changeDate', () ->
    to_day.parent().addClass('is-focused')
  )