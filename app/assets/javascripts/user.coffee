@paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

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
              plotShadow: false
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
  div_plans = document.getElementsByClassName('plans-action')
  div_features = document.getElementsByClassName('users_features')

  if div_plans[0] != undefined
    document.getElementById('activities-user').style.background = '#F0F8FF'
    document.getElementById('all_plans_users').style.background = '#F0F8FF'

  if div_overview[0] != undefined
    document.getElementById('overview-user').style.background = '#F0F8FF'
    user_charts()

  if div_features[0] != undefined
    document.getElementById('features-user').style.background = '#F0F8FF'




$ ->
  default_tab()

  $("button[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
