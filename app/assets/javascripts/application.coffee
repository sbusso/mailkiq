#= require jquery
#= require jquery_ujs
#= require chosen/abstract-chosen
#= require chosen/select-parser
#= require chosen.jquery
#= require clipboard
#= require dropdown
#= require_self
#= require_tree ./modules

@App =
  Dashboard: {}
  Settings: {}

  initializeHighcharts: ->
    Highcharts?.setOptions
      credits:
        enabled: false
      title:
        text: null
      legend:
        itemStyle:
          color: '#4f4f4f'
      chart:
        style:
          fontFamily: 'Montserrat, sans-serif'
      tooltip:
        backgroundColor: '#b8ddff'
        borderWidth: 0
        borderRadius: 0
        hideDelay: 350
        shadow: false
        headerFormat: '<span style="font-size: 12px; color: #808080">{point.key}</span><br/>'
        pointFormat: '<span style="font-size: 20px; color: #4f4f4f; font-weight: bold">{point.y}</span><br/>'
        shape: 'square'
        style:
          padding: '17px 20px'
      plotOptions:
        line:
          marker:
            enabled: true
      series: [{
        type: 'line'
        lineWidth: 2
        zIndex: 10
        marker:
          lineWidth: 2
          radius: 5
      }]
      yAxis:
        title:
          text: null
        gridLineColor: 'transparent'
        minPadding: 0
        allowDecimals: false
        labels:
          style:
            color: '#b3b3b3'
      xAxis:
        type: 'datetime'
        lineColor: '#e1e1e1'
        lineWidth: 1
        tickLength: 5
        tickColor: '#e1e1e1'
        dateTimeLabelFormats:
          day: '%b. %e'
        labels:
          style:
            color: '#b3b3b3'

  launch: ->
    @initializeHighcharts()

    [controller_name, action_name] = $('body').data('route').split('#')
    action_name = action_name.capitalize()

    new App.Common().render()
    new App.Tabs()

    if App[controller_name] and App[controller_name][action_name]
      (new App[controller_name][action_name]).render()

$ ->
  App.launch()
