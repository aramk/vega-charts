TemplateClass = Template.pieChart
TemplateClass.rendered = ->
  $container = @$('.chart-container')
  $parent = $container.parent()
  args = _.extend({}, @data)
  if $parent.length > 0
    width = $parent.width()
    height = $parent.height()
    unless width == 0 || height == 0
      args.width ?= width
      args.height ?= height
  chart = new PieChart(args)
  $container.append(chart.getElement())
