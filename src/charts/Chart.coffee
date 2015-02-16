class Chart

  $em: null

  constructor: (args) ->
    @$em = $('<div class="chart"></div>')
    @items = @generateItems(args.items)
    @addColors(@items, args.colors ? @DEFAULT_COLORS)
    spec = @generateSpec(_.extend(args, {values: @items}))
    console.log('spec', spec)
    vegaOptions = {}
    Vega.render(spec, @$em, vegaOptions)

  getElement: -> @$em

  generateSpec: (args) ->
    args = _.extend({
      width: 400
      height: 400
      paddingForbody: 16
      labels: true
    }, args)

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
