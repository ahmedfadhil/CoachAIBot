@user_charts = () ->
  user_id = document.getElementById('hidden_user_id').value
  $.ajax "/users/#{user_id}/get_charts_data",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->
      console.log data
      for plan in data.plans
        for activity in plan.activities
          options = {
            lang: {
              months: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre',
                'Ottobre', 'Novembre', 'Dicembre'],
              weekdays: ['Domenica', 'Lunedi', 'Martedi', 'Mercoledi', 'Giovedi', 'Venerdi', 'Sabato'],
              shortMonths: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
              loading: "Caricamento..."
            }
          }

          Highcharts.setOptions(options);
          div_completeness_id = "completeness-#{activity.planning_id}"
          Highcharts.chart(div_completeness_id, {
            credits: {
              enabled: false
            },
            chart: {
              plotBackgroundColor: null,
              plotBorderWidth: 0,
              plotShadow: false,
# Edit chart spacing
              spacingBottom: 10,
              spacingTop: 2,
              spacingLeft: 2,
              spacingRight: 20,


# Explicitly tell the width and height of a chart
              width: null,
              height: null,
#              plotBackgroundColor: '#f6fcff',
              animation: {
                duration: 1500,
                easing: 'easeOutBounce'

              },
              borderColor: '#eb982f',
              borderWidth: 0.2,
            },
            colors: ['#6ab344', '#bd0e3d', '#ff861b'],
            title: {
              text: 'Progresso',
              align: 'center',
              verticalAlign: 'bottom',
              x: 0,
              y: -75,
              floating: true
            },
            tooltip: {
              pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
            },
            plotOptions: {
              pie: {
                dataLabels: {
                  enabled: true,
                  distance: 8,
                  style: {
                    fontWeight: 'bold',
                    color: 'red',
                  }
                },
                startAngle: -90,
                endAngle: 90,
                center: ['50%', '70%']

              }
            },
            series: [{
              type: 'pie',
              name: 'Progresso',
              innerSize: '50%',
              data: [
                activity.completeness_data.data[0],
                activity.completeness_data.data[1],
                activity.completeness_data.data[2],
                {
                  name: 'Proprietary or Undetectable',
                  y: 0.2,
                  dataLabels: {
                    enabled: false
                  }
                }
              ]
            }]
          });

          i = 0
          for yes_no_question in activity.yes_no_data
            div_yes_no_id = "yes-no-question-#{i}-#{activity.planning_id}"
            if yes_no_question.data.length > 0
              Highcharts.chart(div_yes_no_id, {
                chart: {
                  plotBackgroundColor: null,
                  plotBorderWidth: 0,
                  plotShadow: false,
# Edit chart spacing
                  spacingBottom: 10,
                  spacingTop: 2,
                  spacingLeft: 2,
                  spacingRight: 2,

# Explicitly tell the width and height of a chart
                  width: null,
                  height: null

                },
                colors: ['#6ab344', '#bd0e3d', '#ff861b'],
                title: {
                  text: yes_no_question.text,
                  align: 'center',
                  verticalAlign: 'bottom',
                  x: 0,
                  y: -75,
                  floating: true
                },
                tooltip: {
                  pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                },
                plotOptions: {
                  pie: {
                    dataLabels: {
                      enabled: true,
                      distance: -50,
                      style: {
                        fontWeight: 'bold',
                        color: 'white'
                      }
                    },
                    startAngle: -90,
                    endAngle: 90,
                    center: ['50%', '75%']
                  }
                },
                series: [{
                  type: 'pie',
                  name: yes_no_question.text,
                  innerSize: '50%',
                  data: [
                    yes_no_question.data[0],
                    yes_no_question.data[1],
                    {
                      name: 'Proprietary or Undetectable',
                      y: 0.2,
                      dataLabels: {
                        enabled: false
                      }
                    }
                  ]
                }]
              });


          i = 0
          for scalar_adherence in activity.scalar_data
            div_scalar_id = "scalar-adherence-#{i}-#{activity.planning_id}"
            if scalar_adherence.data.length > 0
              Highcharts.setOptions(options);
              Highcharts.chart(div_scalar_id, {
                chart: {
                  type: 'area'
                },
                title: {
                  text: scalar_adherence.text
                },
                xAxis: {
                  type: 'datetime',
                  allowDecimals: false,
                  title: {
                    text: 'Tempo'
                  }
                },
                yAxis: {
                  title: {
                    text: scalar_adherence.text
                  }
                },
                series: [{
                  name: 'Andamento',
                  data: scalar_adherence.data
                }]
              });
              i++

          i = 0
          for open_question in activity.open_data
            div_open_id = "open-question-#{i}-#{activity.planning_id}"
            console.log open_question.data
            if open_question.data.length > 0
              Highcharts.chart(div_open_id, {
                chart: {
                  type: 'column'
                },
                title: {
                  text: open_question.text
                },
                subtitle: {
                  text: 'Questo graffico illustra la distribuzione in percentuale delle risposte date fino ad oggi alla domanda scritta sopra'
                },
                xAxis: {
                  categories: [
                    'Risposte alla Domanda'
                  ],
                  crosshair: true
                },
                yAxis: {
                  min: 0,
                  title: {
                    text: open_question.text

                  }
                },
                tooltip: {
                  headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                  pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                    '<td style="padding:0"><b>{point.y:.1f} %</b></td></tr>',
                  footerFormat: '</table>',
                  shared: true,
                  useHTML: true
                },
                plotOptions: {
                  column: {
                    pointPadding: 0.2,
                    borderWidth: 0
                  }
                },
                series: open_question.data
              });




@default_tab = () ->
  div_overview = document.getElementsByClassName('overview-action')
  div_plans = document.getElementById('all_plans_users')
  div_features = document.getElementsByClassName('features-page')
  div_index = document.getElementsByClassName('users-index')
  div_chat = document.getElementsByClassName('chat-container')


  if div_chat[0] != undefined
    document.getElementById('chatting-user').style.background = '#757575'

  if div_plans != null
    document.getElementById('activities-user').style.background = '#757575'
    document.getElementById('all_plans_users').style.background = '#757575'

  if div_overview[0] != undefined
    document.getElementById('overview-user').style.background = '#757575'
    user_charts()

  if div_features[0] != undefined
    document.getElementById('features-user').style.background = '#757575'

  if div_index[0] != undefined
    document.getElementById('all-users').style.background = '#757575'
    getScores()
    getImages()



@show_hide = (element, type) ->
  if type == 'open'
    $('.numeric-answers').css('display', 'none')
    $('.open-answers').css('display', 'block')
  else if type == 'scalar'
    $('.numeric-answers').css('display', 'block')
    $('.open-answers').css('display', 'none')
  else if type == 'yes-no'
    $('.numeric-answers').css('display', 'none')
    $('.open-answers').css('display', 'none')


@assign_to_hidden = (element, type) ->
  if type == 'from'
    $('#scalar_from_val').val($('#scalar_from').val())
  else if type == 'to'
    $('#scalar_to_val').val($('#scalar_to').val())
  else
    $('#open_answer_val').val($('#open-answers').val())

@animate = (bar, type, user) ->
  switch type
    when 0
      bar.animate user.diet_score / 100
    when 1
      bar.animate user.physical_score / 100
    else
      bar.animate user.mental_score / 100

@get_labels_name = (type) ->
  switch type
    when 0
      ['<i class="material-icons md-36">room_service</i>', 'diet']
    when 1
      ['<i class="material-icons md-36">directions_bike</i>', 'physical']
    else
      ['<i class="material-icons md-36">local_florist</i>', 'mental']
#      consider adding more...

@score = (user, type) ->
  labels = get_labels_name(type)
  bar = new (ProgressBar.Circle)("##{labels[1]}_score_#{user.id}",
    strokeWidth: 10
    color: '#FF0000'
    trailColor: '#787878'
    trailWidth: 10
    easing: 'easeInOut'
    duration: 1400
    svgStyle: null
    text:
      value: labels[0]
      alignToBottom: false
      style:
        color: '#000000'
        position: 'relative'
        left: '0',
        top: '-72%',
        padding: 0,
        margin: 0,
    from:
      color: '#FF0000'
    to:
      color: '#008000'
    step: (state, semicircle, attachment) ->
      semicircle.path.setAttribute('stroke', state.color)
    autoStyleContainer: false
  )
  bar.text.style.fontFamily = '"Raleway", Helvetica, sans-serif'
  bar.text.style.fontSize = '15px'
  bar.text = labels[0]
  animate(bar, type, user)

@add_image_tag = (user) ->
  div_id = "profile-img-user-#{user.id}"
  div = $("##{div_id}")
  div.prepend('<img class="user-img-round" src="' + user.profile_img + '" />')

@getScores = () ->
  $.ajax "/users/get_scores",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->
      for user in data.users
        score(user, 0)
        score(user, 1)
        score(user, 2)

@getImages = () ->
  $.ajax "/users/get_images",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->
      for user in data.users
        add_image_tag(user)


@addTips = () ->
  Tipped.create('.chat-with-user', 'Chatta con il Paziente')
  Tipped.create('.archive-user', 'Archivia il Paziente')


$ ->
  default_tab()
  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")

    $('.datepicker').datepicker () ->
      weekStart: 1

  $("tr[data-href]").click (e) ->
    e.preventDefault()
    window.location = $(this).data("href");

  addTips()


  $ ->
    flashCallback = ->
      $(".alert").fadeOut()
    $(".alert").bind 'click', (ev) =>
      $(".alert").fadeOut()
    setTimeout flashCallback, 9000