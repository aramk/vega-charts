class LineChart extends Chart

  generateSpec: (args) ->
    args = _.extend({
      width: 400
      height: 400
      # paddingForbody: 16
    }, args)
    values = args.values
    # paddingDiff = 2 * args.paddingForbody
    width = args.width# -= paddingDiff
    height = args.height# -= paddingDiff
    labels = args.labels
    _.extend({
      width: width,
      height: height,
      data: [
        {
          name: 'values',
          values: values,
          format: {
            type: 'json',
            parse: args.format
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
        {type: 'y', scale: 'y', title: labels?.y}
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
    }, args)

  generateItems: (values) ->
    if Types.isObject(values)
      items = []
      _.each values, (series, label) ->
        _.each series, (yValue, xValue) ->
          items.push({label: label, x: xValue, y: yValue})
    else if Types.isArray(values)
      items = values
    else
      throw new Error('Invalid arguments')
    items
