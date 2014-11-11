class PieChart

  $em: null

  constructor: (args) ->
    @$em = $('<div class="chart"></div>')
    items = @generateItems(args.items)
    @addColors(items, args.colors ? @DEFAULT_COLORS)
    spec = @generateSpec(_.extend(args, {values: items}))
    valueSum = Maths.sum items, (item) -> item.value
    vegaOptions = {}
    vegaDf = Vega.render(spec, @$em, vegaOptions)
    formatterDf = args.formatter
    unless formatterDf && formatterDf.then?
      formatterDf = Q.defer()
      formatterDf.resolve(args.formatter)
    Q.all([vegaDf, formatterDf]).then (results) ->
      [vegaResult, formatter] = results
      view = vegaResult.view
      popups = []
      view.on 'mouseover', (event, item) ->
        data = item.datum.data
        index = item.datum.index
        $popup = popups[index]
        unless $popup
          value = data.value
          units = data.units
          percentage = value / valueSum
          if formatter
            value = formatter(value)
          else
            round = data.round ? 2
            value = value.toFixed(round) if round
          title = '<div class="label">' + data.label + '</div>'
          title += '<div class="percentage">' + Strings.format.percentage(percentage) + '</div>'
          body = data.text
          unless body
            body = '<div class="value">' + value + '</div>'
            body += '<div class="units">' + units + '</div>' if units?
          $popup = createPopup(title: title, body: body)
          popups[index] = $popup
          $('body').append($popup)
        $popup.show()
        setPositionFromEvent($popup, event)
      view.on 'mousemove', (event, item) ->
        index = item.datum.index
        $popup = popups[index]
        setPositionFromEvent($popup, event)
      view.on 'mouseout', (event, item) ->
        index = item.datum.index
        $popup = popups[index]
        $popup.hide() if $popup

  getElement: -> @$em

  generateSpec: (args) ->
    args = _.extend({
      width: 400
      height: 400
      paddingForbody: 16
      labels: true
    }, args)
    values = args.values
    width = args.width
    height = args.height
    paddingForbody = args.paddingForbody
    radius = args.radius ? Math.min(height, width) / 2 - paddingForbody
    spec = _.extend({
      width: width,
      height: height,
      data: [
        {
          name: 'table',
          values: values,
          transform: [
            {type: 'pie', value: 'data.value'}
          ]
        }
      ],
      marks: [
        {
          type: 'arc',
          from: {data: 'table'},
          properties: {
            enter: {
              x: {group: 'width', mult: 0.5},
              y: {group: 'height', mult: 0.5},
              startAngle: {field: 'startAngle'},
              endAngle: {field: 'endAngle'},
              innerRadius: {value: 0},
              outerRadius: {value: radius},
              stroke: {value: '#fff'}
            },
            update: {
              fill: {field: 'data.color'},
              fillOpacity: {value: 1}
            },
            hover: {
              fillOpacity: {value: 0.6}
            }
          }
        }
      ]
    }, args)
    if args.labels
      spec.marks.push({
        type: 'body',
        from: {data: 'table'},
        properties: {
          enter: {
            x: {group: 'width', mult: 0.5},
            y: {group: 'height', mult: 0.5},
            radius: {value: radius, offset: paddingForbody / 2},
            theta: {field: 'midAngle'},
            fill: {value: '#000'},
            align: {value: 'center'},
            baseline: {value: 'middle'},
            body: {field: 'data.label'}
          },
          hover: {
            body: {field: 'data.value'}
          }
        }
      })
    spec

  generateItems: (values) ->
    if Types.isObject(values)
      items = []
      _.each values, (value, label) ->
        item = if Types.isObject(value) then value else {value: value}
        item.label = label
        items.push(item)
    else if Types.isArray(values)
      items = values
    else
      throw new Error('Invalid arguments')
    items

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

  createPopup = (data) ->
    $em = $('<div class="chart-popup"></div>')
    title = data.title
    body = data.body
    $em.append($('<div class="title">' + title + '</div>')) if title?
    $em.append($('<div class="body">' + body + '</div>')) if body?
    $em

  setPositionFromEvent = ($em, event) ->
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
