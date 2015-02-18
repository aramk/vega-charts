class LineChart extends Chart

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
      divisor = 1
      if tens > 1
        divisor = Math.pow(10, tens)
        _.each values, (value) ->
          value.y /= divisor
        yLabel += ' (x10^' + tens + ')'

    _.extend({
      data: [
        {
          name: 'values',
          values: values,
          format: {
            type: 'json',
            parse: spec.format
          }
        }
      ],
      scales: [
        {
          name: 'x',
          type: 'time',
          range: 'width',
          domain: {data: 'values', field: 'data.x'}
        },
        {
          name: 'y',
          type: 'linear',
          range: 'height',
          nice: true,
          domain: {data: 'values', field: 'data.y'}
        },
        {
          name: 'color', type: 'ordinal', range: 'category10'
        }
      ],
      axes: [
        {type: 'x', scale: 'x', tickSizeEnd: 0, title: labels?.x},
        {type: 'y', scale: 'y', title: yLabel}
      ],
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
    if Types.isObject(values)
      items = []
      _.each values, (series, label) ->
        _.each series, (datum) ->
          items.push({label: label, x: datum.x, y: datum.y})
    else if Types.isArray(values)
      items = values
    else
      throw new Error('Invalid arguments')
    items
