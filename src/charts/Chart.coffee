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
    args = Setter.merge Setter.clone(@options), args, {values: @items}
    spec = @generateSpec(args)
    Logger.debug('Chart spec', spec, args)
    @renderPromise = Vega.render(spec, @$em, args)

    if args.popups
      Q.all([@renderPromise, args.formatter]).then (results) =>
        [vegaResult, formatter] = results
        view = vegaResult.view
        valueSum = Maths.sum @items, (item) -> item.value
        popups = []
        getOrCreatePopup = (item) =>
          index = item.datum.index
          $popup = popups[index]
          unless $popup
            $popup = @createPopup(item, valueSum, formatter)
            $('body').append($popup)
            popups[index] = $popup
          $popup
        view.on 'mouseover', (event, item) =>
          $popup = getOrCreatePopup(item)
          if $popup
            $popup.show()
            @setPositionFromEvent($popup, event)
        view.on 'mousemove', (event, item) =>
          $popup = getOrCreatePopup(item)
          @setPositionFromEvent($popup, event) if $popup
        view.on 'mouseout', (event, item) ->
          $popup = getOrCreatePopup(item)
          $popup.hide() if $popup

    @renderPromise

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
    itemColors = Setter.clone(colors)
    lenDiff = values.length - colors.length
    if lenDiff > 0
      # Generate unique colors for remaining items which cannot be assigned one of the predefined
      # colors.
      itemColors = itemColors.concat(@generateUniqueColors(colors, lenDiff))
    _.each values, (item) ->
      item.color ?= itemColors.shift()

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

  createPopup: (item, valueSum, formatter) ->
    data = item.datum.data
    index = item.datum.index
    value = data.value
    units = data.units
    percentage = value / valueSum
    if formatter
      try
        value = formatter(value)
      catch e
        console.error('Error formatting popup', e)
    else
      round = data.round ? 2
      value = value.toFixed(round) if round
    title = '<div class="label">' + data.label + '</div>'
    title += '<div class="percentage">' + Strings.format.percentage(percentage) + '</div>'
    body = data.text
    unless body
      body = '<div class="value">' + value + '</div>'
      body += '<div class="units">' + units + '</div>' if units?
    @createPopupElement(title: title, body: body)

  setPositionFromEvent: ($em, event) ->
    offset = {x: 10, y: 0}
    $em.css('left', event.clientX + offset.x)
    $em.css('top', event.clientY + offset.y)

  DEFAULT_COLORS: [
    '#3695ff'
    '#75b313'
    '#ffba14'
    '#7c3dff'
    '#00e37d'
    '#ff9314'
    '#ff1414'
    '#f9ec15'
    '#7f0894'
    '#b6095b'
  ]

  RAINBOW_COLORS: [
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
