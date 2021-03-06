class LineChart extends Chart

  # @type {Object.<String, Object>} Options for each series.
  seriesMap: null

  constructor: (args) ->
    @seriesMap = {}
    super(args)

  generateSpec: (spec) ->
    spec = super(spec)
    values = spec.values
    labels = spec.labels

    yLabel = labels?.y
    if yLabel
      # Truncate the values in the y-axis so they don't overflow onto the label.
      yValueLengths = _.map values, (value) -> (Math.floor(value.y).toString() ? '').length
      maxYLength = _.max yValueLengths
      tens = maxYLength - 1
      digitLimit = 3
      tens = tens - (tens % digitLimit)
      if tens > 1
        divisor = Math.pow(10, tens)
        _.each values, (value) ->
          value.y /= divisor
        yLabel += ' (x10^' + tens + ')'

    data = [
      {
        name: 'values',
        values: values,
        format: {
          type: 'json',
          parse: spec.format
        }
      }
    ]
    
    xScale =
      name: 'x'
      type: 'linear'
      range: 'width'
      domain: {data: 'values', field: 'data.x'}
    if @options.format?.x == 'date'
      xScale.type = 'time'
    yScale =
      name: 'y'
      type: 'linear'
      range: 'height'
      nice: true
      domain: {data: 'values', field: 'data.y'}
    scales = [xScale, yScale]

    axesX = {type: 'x', scale: 'x', tickSizeEnd: 0, title: labels?.x, format: 'd'}
    axesY = {type: 'y', scale: 'y', title: yLabel}
    axes = [axesX, axesY]
    axesOptions = @options.axes
    if axesOptions
      _.extend axesX, axesOptions.x
      _.extend axesY, axesOptions.y
      delete spec.axes
    seriesArray = _.values(@seriesMap)

    seriesData = {
      name: 'series',
      values: seriesArray
    }
    data.push(seriesData)

    hasColors = _.some seriesArray, (series) -> return true if series.color
    if hasColors
      defaultColors = @generateUniqueColors(@DEFAULT_COLORS, seriesArray.length)
      _.each @seriesMap, (series, label) ->
        unless series.color
          series.color = defaultColors.pop()
      # Provide a set of colors from the series data. The line mark then selects the same color for
      # each different label value.
      scales.push({name: 'color', type: 'ordinal', range: {data: 'series', field: 'data.color'}})
    else
      scales.push({name: 'color', type: 'ordinal', range: 'category10'})

    _.extend({
      data: data,
      scales: scales,
      axes: axes,
      marks: [
        {
          type: 'group',
          from: {
            data: 'values',
            transform: [{type: 'facet', keys: ['data.label']}]
          },
          marks: [
            {
              type: 'line',
              properties: {
                enter: {
                  x: {scale: 'x', field: 'data.x'},
                  y: {scale: 'y', field: 'data.y'},
                  stroke: {scale: 'color', field: 'data.label'},
                  strokeWidth: {value: 2}
                }
              }
            },
            {
              type: 'text',
              from: {
                transform: [{type: 'filter', test: 'index==data.length-1'}]
              },
              properties: {
                enter: {
                  x: {scale: 'x', field: 'data.x', offset: 2},
                  y: {scale: 'y', field: 'data.y'},
                  fill: {scale: 'color', field: 'data.label'},
                  text: {field: 'data.label'},
                  baseline: {value: 'middle'}
                }
              }
            }
          ]
        }
      ]
    }, spec)

  generateItems: (values) ->
    if Types.isObjectLiteral(values)
      items = []
      _.each values, (series, label) =>
        if Types.isArray(series)
          series = {values: series}
        @seriesMap[label] = series
        _.each series.values, (datum) ->
          item = {x: datum.x, y: datum.y}
          items.push(item)
          label = series.label ? label
          if label == false
            label = ''
          item.label = label
    else if Types.isArray(values)
      items = values
    else
      throw new Error('Invalid arguments')
    items
