TemplateClass = Template.chart

ChartClasses =
  line: LineChart
  pie: PieChart

TemplateClass.rendered = ->
  $container = @$('.chart-container')
  $title = @$('.chart-title')
  
  # Allow either attributes or a "settings" object.
  settings = @data.settings
  delete @data.settings
  args = _.extend({
    resizeContainer: false
    container: $container
  }, settings, @data)
  
  type = args.type
  unless type
    throw new Error('Chart type not provided.')
  ChartClass = ChartClasses[type]
  unless ChartClass
    throw new Error('Chart type not recognised: ' + type)
  
  chart = new ChartClass(args)
  $chart = chart.getElement()
  $container.append($chart)
  $container.toggle(chart.items.length != 0)
  # Delay rendering to allow resizing to the container size.
  chart.render()

  if args.resizeContainer
    chart.renderPromise.then ->
      $canvas = $('canvas', $chart)
      width = $canvas.width()
      $container.width(width) if width > 0

  if args.title
    $title.html(args.title)
