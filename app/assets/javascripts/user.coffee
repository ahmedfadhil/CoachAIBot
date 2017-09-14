chart1 = null
usdtoeur = [10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,10,20,11,23,]

@paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

@firstChart = () ->
  user_id = document.getElementById('hidden_user_id').valueOf()
  $.ajax "/#{user_id}/get_charts_data",
    type: 'GET'
    dataType: 'json'
    json: true  s
    success: (data, textStatus, jqXHR) ->
      $('body').append "Successful AJAX call: #{data.status}"


  myChart = Highcharts.chart('graphs-container', {
    chart: {
      type: 'bar'
    },
    title: {
      text: 'Fruit Consumption'
    },
    xAxis: {
      categories: ['Apples', 'Bananas', 'Oranges']
    },
    yAxis: {
      title: {
        text: 'Fruit eaten'
      }
    },
    series: [{
      name: 'Jane',
      data: [1, 0, 4]
    }, {
      name: 'John',
      data: [5, 7, 3]
    }]
  })

  chart1 = Highcharts.stockChart('highstack', {
    rangeSelector: {
      selected: 1
    },
    series: [{
      name: 'USD to EUR',
      data: usdtoeur
    }]
  })


@default_tab = () ->
  div_overview = document.getElementsByClassName('overview-action')
  div_plans = document.getElementsByClassName('plans-action')
  div_features = document.getElementsByClassName('users_features')

  if div_plans[0] != undefined
    document.getElementById('activities-user').style.background = '#F0F8FF'
    document.getElementById('all_plans_users').style.background = '#F0F8FF'

  if div_overview[0] != undefined
    firstChart()
    document.getElementById('overview-user').style.background = '#F0F8FF'

  if div_features[0] != undefined
    document.getElementById('features-user').style.background = '#F0F8FF'




$ ->
  default_tab()

  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
