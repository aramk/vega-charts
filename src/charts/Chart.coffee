class Chart

  $em: null
  $container: null
  options: null
  renderPromise: null

  constructor: (args) ->
    @options = args ?= {}
    @$em = $(args.element ? '<div class="chart"></div>')
    # The container is used to determine the bounding dimensions of the chart.
    @$container = $(args.container ? @$em)
    # Remove so cloning in Vega doesn't use the elements.
    delete args.container
    delete args.element

    items = args.items
    unless items
      throw new Error('No items provided')
    @items = @generateItems(items)
    @addColors(@items, args.colors ? @DEFAULT_COLORS)


  render: (args) ->
    args = _.extend(@options, args)
    spec = @generateSpec(_.extend(args, {values: @items}))
    console.log('spec', spec)
    @renderPromise = Vega.render(spec, @$em, args)

  getElement: -> @$em

  # @param {Object} [spec] The spec object expected by Vega.
  # @param {Boolean|Object} [args.resize=false] - Whether to resize the chart based on the
  #      space available to the container element. If an object is provided, it can contain "height"
  #      and "width" components. This overrides any height or width values in the spec. If the
  #      container element isn't in the DOM, this setting will have no effect since its bounding
  #      dimensions cannot be determined.
  generateSpec: (spec) ->
    spec = _.extend({
      width: 400
      height: 400
      paddingForbody: 16
      labels: true
    }, spec)
    resize = spec.resize
    $parent = @$container.parent()
    if resize && $parent
      if resize == true
        resize = {width: true, height: true}
      padding = _.extend({top: 0, bottom: 0, left: 0, right: 0}, spec.padding)
      parentWidth = $parent.width()
      parentHeight = $parent.height()
      # Ignore 0 width or height values.
      if resize.width && parentWidth
        spec.width = parentWidth - padding.left - padding.right
      if resize.height && parentHeight
        spec.height = parentHeight - padding.top - padding.bottom
    spec

  generateItems: (values) -> values

  addColors: (values, colors) ->
    itemColors = @generateUniqueColors(colors, values.length)
    _.each values, (item) ->
      item.color ?= itemColors.pop()

  generateUniqueColors: (colors, size) ->
    colors = _.shuffle(colors)
    results = []
    colorsLen = colors.length
    _.times size, (i) ->
      if i < colorsLen
        results.push(colors[i])
      else
        color = results[i - colorsLen]
        results.push(tinycolor(color).darken(0.1).toHexString())
    results

  createPopupElement: (data) ->
    $em = $('<div class="chart-popup"></div>')
    title = data.title
    body = data.body
    $em.append($('<div class="title">' + title + '</div>')) if title?
    $em.append($('<div class="body">' + body + '</div>')) if body?
    $em

  setPositionFromEvent: ($em, event) ->
    offset = {x: 10, y: 0}
    $em.css('left', event.clientX + offset.x)
    $em.css('top', event.clientY + offset.y)

  DEFAULT_COLORS: [
    '#ff1414'
    '#ff9314'
    '#ffba14'
    '#f9ec15'
    '#75b313'
    '#00e37d'
    '#3695ff'
    '#7c3dff'
    '#7f0894'
    '#b6095b'
  ]
