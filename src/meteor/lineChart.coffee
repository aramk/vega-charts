TemplateClass = Template.lineChart
TemplateClass.rendered = ->
  $container = @$('.chart-container')
  args = _.extend({
    resize: true
  }, @data)
  if $container.length > 0 || !args.resize
    width = $container.width()
    height = $container.height()
    args.width ?= width unless width == 0
    args.height ?= height unless height == 0
  chart = new LineChart(args)
  $chart = chart.getElement()
  $container.append($chart)
  $container.toggle(chart.items.length != 0)
