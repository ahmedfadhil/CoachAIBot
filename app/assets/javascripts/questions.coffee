@show_hide = (element, type) ->
  if type=='open'
    $('.numeric-answers').css('display', 'none')
    $('.open-answers').css('display', 'block')
  else if type=='scalar'
    $('.numeric-answers').css('display', 'block')
    $('.open-answers').css('display', 'none')
  else if type=='yes-no'
    $('.numeric-answers').css('display', 'none')
    $('.open-answers').css('display', 'none')


$ ->
  $('input[type="radio"][data-answers]').change (e) ->
    e.preventDefault()

    type = $(this).data("answers")
    show_hide(this, type)


@assign_to_hidden = (element, type) ->
  if type=='from'
    $('#scalar_from_val').val($('#scalar_from').val())
  else if type=='to'
    $('#scalar_to_val').val($('#scalar_to').val())
  else
    $('#open_answer_val').val($('#open-answers').val())


$ ->
  $('input[data-answer]').change (e) ->
    e.preventDefault()

    type = $(this).data("answer")
    assign_to_hidden(this, type)
