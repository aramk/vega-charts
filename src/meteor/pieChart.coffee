TemplateClass = Template.pieChart
TemplateClass.rendered = ->
  $container = @$('.chart-container')
  # $parent = $container.parent()
  args = _.extend({
    resize: true
  }, @data)
  if $container.length > 0 || !args.resize
    width = $container.width()
    height = $container.height()
    args.width ?= width unless width == 0
    args.height ?= height unless height == 0
  chart = new PieChart(args)
  $container.append(chart.getElement())
