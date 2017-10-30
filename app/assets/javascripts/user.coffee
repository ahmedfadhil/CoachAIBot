###

Highcharts.createElement('link', {
  href: 'https://fonts.googleapis.com/css?family=Unica+One',
  rel: 'stylesheet',
  type: 'text/css'
}, null, document.getElementsByTagName('head')[0]);

Highcharts.theme = {
  colors: ['#2b908f', '#90ee7e', '#f45b5b', '#7798BF', '#aaeeee', '#ff0066', '#eeaaee',
    '#55BF3B', '#DF5353', '#7798BF', '#aaeeee'],
  chart: {
    backgroundColor: {
      linearGradient: { x1: 0, y1: 0, x2: 1, y2: 1 },
      stops: [
        [0, '#2a2a2b'],
        [1, '#3e3e40']
      ]
    },
    style: {
      fontFamily: '\'Unica One\', sans-serif'
    },
    plotBorderColor: '#606063'
  },
  title: {
    style: {
      color: '#E0E0E3',
      textTransform: 'uppercase',
      fontSize: '20px'
    }
  },
  subtitle: {
    style: {
      color: '#E0E0E3',
      textTransform: 'uppercase'
    }
  },
  xAxis: {
    gridLineColor: '#707073',
    labels: {
      style: {
        color: '#E0E0E3'
      }
    },
    lineColor: '#707073',
    minorGridLineColor: '#505053',
    tickColor: '#707073',
    title: {
      style: {
        color: '#A0A0A3'

      }
    }
  },
  yAxis: {
    gridLineColor: '#707073',
    labels: {
      style: {
        color: '#E0E0E3'
      }
    },
    lineColor: '#707073',
    minorGridLineColor: '#505053',
    tickColor: '#707073',
    tickWidth: 1,
    title: {
      style: {
        color: '#A0A0A3'
      }
    }
  },
  tooltip: {
    backgroundColor: 'rgba(0, 0, 0, 0.85)',
    style: {
      color: '#F0F0F0'
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
      color: '#E0E0E3'
    },
    itemHoverStyle: {
      color: '#FFF'
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

###

@user_charts = () ->
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

@getScores = () ->
  $.ajax "/users/get_scores",
    type: 'GET'
    dataType: 'json'
    json: true
    success: (data, textStatus, jqXHR) ->




@default_tab = () ->
  div_overview = document.getElementsByClassName('overview-action')
  div_plans = document.getElementsByClassName('plans-action')
  div_features = document.getElementsByClassName('users_features')
  div_index = document.getElementsByClassName('users-index')

  if div_plans[0] != undefined
    document.getElementById('activities-user').style.background = '#F0F8FF'
    # document.getElementById('all_plans_users').style.background = '#F0F8FF'

  if div_overview[0] != undefined
    document.getElementById('overview-user').style.background = '#F0F8FF'
    user_charts()

  if div_features[0] != undefined
    document.getElementById('features-user').style.background = '#F0F8FF'

  if div_index[0] != undefined
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


$ ->
  default_tab()

  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")

    $('.datepicker').datepicker () ->
      weekStart:1

