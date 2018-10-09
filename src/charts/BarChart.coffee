class BarChart extends Chart

  # @type {Object.<String, Object>} Options for each series.
  seriesMap: null

  constructor: (args) ->
    super(args)
    @seriesMap = {}

  render: (args) ->
    args = _.extend(@options, {
      popups: true
    }, args)
    super(args)

  generateSpec: (spec) ->
    spec = super(spec)
    values = spec.values
    labels = spec.labels

    xLabel = labels?.x
    yLabel = labels?.y

    data = [
      {
        name: 'values',
        values: values
      }
    ]
    
    xScale =
      name: 'xscale'
      type: 'ordinal'
      range: 'width'
      domain: {data: 'values', field: 'index'}
    if @options.format?.x == 'date'
      xScale.type = 'time'
    yScale =
      name: 'yscale'
      range: 'height'
      nice: true
      zero: true
      round: true
      domain: {data: 'values', field: 'data.value'}
    
    scales = [xScale, yScale]

    axesX = {type: 'x', scale: 'xscale', title: xLabel}
    axesY = {type: 'y', scale: 'yscale', title: yLabel, properites: {
      "axis": {
        "stroke": {
          "value": "transparent"
        }
      }
    }}
    axes = []
    unless @options.xAxis == false then axes.push(axesX)
    unless @options.yAxis == false then axes.push(axesY)
    axesOptions = @options.axes
    if axesOptions
      _.extend axesX, axesOptions.x
      _.extend axesY, axesOptions.y
      delete spec.axes

    return _.extend({
      data: data,
      scales: scales,
      axes: axes,
      marks: [
        {
          type: 'rect',
          from: {
            data: 'values'
          },
          properties: {
            enter: {
              x: {scale: 'xscale', field: 'index'},
              width: {scale: 'xscale', band: true, offset: -1},
              y: {scale: 'yscale', field: 'data.value'},
              y2: {scale: 'yscale', value: 0},
              fill: {field: 'data.color'}
            }
          }
        }
      ]
    }, spec)

  generateItems: (values) ->
    if Types.isObjectLiteral(values)
      items = []
      _.each values, (value, label) ->
        item = if Types.isObject(value) then value else {value: value}
        item.label ?= label
        items.push(item)
    else if Types.isArray(values)
      items = values
    else
      throw new Error('Invalid arguments')
    items
