@load_dark_theme = () ->
  Highcharts.createElement('link', {
    href: 'https://fonts.googleapis.com/css?family=Unica+One',
    rel: 'stylesheet',
    type: 'text/css'
  }, null, document.getElementsByTagName('head')[0]);

  Highcharts.theme = {
    colors: ['#2b908f', '#90ee7e', '#f45b5b', '#7798BF', '#aaeeee', '#ff0066', '#eeaaee',
      '#55BF3B', '#DF5353', '#7798BF', '#aaeeee'],
    chart: {
      backgroundColor: null,
      style: {
        fontFamily: '\'Raleway\', sans-serif',
      },
      plotBorderColor: '#606063'
    },
    title: {
      style: {
        color: '#0b0b0b',
        textTransform: 'uppercase',
        fontSize: '22px'
      }
    },
    subtitle: {
      style: {
        color: '#0b0b0b',
        textTransform: 'uppercase'
      }
    },
    xAxis: {
      gridLineColor: '#707073',
      labels: {
        style: {
          color: '#363637'
        }
      },
      lineColor: '#707073',
      minorGridLineColor: '#505053',
      tickColor: '#707073',
      title: {
        style: {
          color: '#363637'

        }
      }
    },
    yAxis: {
      gridLineColor: '#707073',
      labels: {
        style: {
          color: '#363637',
        }
      },
      lineColor: '#707073',
      minorGridLineColor: '#505053',
      tickColor: '#707073',
      tickWidth: 1,
      title: {
        style: {
          color: '#363637'
        }
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.85)',
      style: {
        color: '#F0F0F0'
        fontSize: '16px'
      }
    },
    plotOptions: {
      series: {
        dataLabels: {
          color: '#B0B0B3'
        },
        marker: {
          lineColor: '#333'
        }
      },
      boxplot: {
        fillColor: '#505053'
      },
      candlestick: {
        lineColor: 'white'
      },
      errorbar: {
        color: 'white'
      }
    },
    legend: {
      itemStyle: {
        color: '#292929'
      },
      itemHoverStyle: {
        color: '#000000'
      },
      itemHiddenStyle: {
        color: '#606063'
      }
    },
    credits: {
      style: {
        color: '#666'
      }
    },
    labels: {
      style: {
        color: '#707073'
      }
    },

    drilldown: {
      activeAxisLabelStyle: {
        color: '#F0F0F3'
      },
      activeDataLabelStyle: {
        color: '#F0F0F3'
      }
    },

    navigation: {
      buttonOptions: {
        symbolStroke: '#DDDDDD',
        theme: {
          fill: '#505053'
        }
      }
    },

  # scroll charts
    rangeSelector: {
      buttonTheme: {
        fill: '#505053',
        stroke: '#000000',
        style: {
          color: '#CCC'
        },
        states: {
          hover: {
            fill: '#707073',
            stroke: '#000000',
            style: {
              color: 'white'
            }
          },
          select: {
            fill: '#000003',
            stroke: '#000000',
            style: {
              color: 'white'
            }
          }
        }
      },
      inputBoxBorderColor: '#505053',
      inputStyle: {
        backgroundColor: '#333',
        color: 'silver'
      },
      labelStyle: {
        color: 'silver'
      }
    },

    navigator: {
      handles: {
        backgroundColor: '#666',
        borderColor: '#AAA'
      },
      outlineColor: '#CCC',
      maskFill: 'rgba(255,255,255,0.1)',
      series: {
        color: '#7798BF',
        lineColor: '#A6C7ED'
      },
      xAxis: {
        gridLineColor: '#505053'
      }
    },

    scrollbar: {
      barBackgroundColor: '#808083',
      barBorderColor: '#808083',
      buttonArrowColor: '#CCC',
      buttonBackgroundColor: '#606063',
      buttonBorderColor: '#606063',
      rifleColor: '#FFF',
      trackBackgroundColor: '#404043',
      trackBorderColor: '#404043'
    },

  # special colors for some of the
    legendBackgroundColor: 'rgba(0, 0, 0, 0.5)',
    background2: '#505053',
    dataLabelsColor: '#B0B0B3',
    textColor: '#C0C0C0',
    contrastTextColor: '#F0F0F3',
    maskColor: 'rgba(255,255,255,0.3)'
  };

  # Apply the theme
  Highcharts.setOptions(Highcharts.theme);

@user_charts = () ->
  load_dark_theme()
  user_id = document.getElementById('hidden_user_id').value
  $.ajax "/users/#{user_id}/get_charts_data",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->
      for plan in data.plans
        for activity in plan.activities
          options = {
            lang: {
              months: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
              weekdays: ['Domenica', 'Lunedi', 'Martedi', 'Mercoledi', 'Giovedi', 'Venerdi', 'Sabato'],
              shortMonths: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
              loading: "Caricamento..."
            }
          }

          Highcharts.setOptions(options);
          div_completeness_id = "completeness-#{activity.planning_id}"
          Highcharts.chart(div_completeness_id, {
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
          for scalar_adherence in activity.scalar_data
            div_scalar_id = "scalar-adherence-#{i}-#{activity.planning_id}"
            if scalar_adherence.data.length>0
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


@assign_to_hidden = (element, type) ->
  if type=='from'
    $('#scalar_from_val').val($('#scalar_from').val())
  else if type=='to'
    $('#scalar_to_val').val($('#scalar_to').val())
  else
    $('#open_answer_val').val($('#open-answers').val())

@animate = (bar, type, user) ->
  switch type
    when 0
      bar.animate user.diet_score/100
    when 1
      bar.animate user.physical_score/100
    else
      bar.animate user.mental_score/100

@get_labels_name = (type) ->
  switch type
    when 0
      ['Attivita\' Fisica', 'physical']
    when 1
      ['Dieta', 'diet']
    else
      ['Mentale', 'mental']

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
    from: color: '#FF0000'
    to: color: '#008000'
    step: (state, semicircle, attachment) ->
      semicircle.path.setAttribute('stroke', state.color)
    autoStyleContainer: false
  )
  bar.text.style.fontFamily = '"Raleway", Helvetica, sans-serif'
  bar.text.style.fontSize = '15px'
  bar.text = labels[0]
  animate(bar, type, user)

@getScores = () ->
  $.ajax "/users/get_scores",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->
      for user in data.users
        console.log user
        score(user, 0)
        score(user, 1)
        score(user, 2)





$ ->
  default_tab()
  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")

    $('.datepicker').datepicker () ->
      weekStart:1

  $("tr[data-href]").click (e) ->
    e.preventDefault()
    window.location = $(this).data("href");
