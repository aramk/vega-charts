class PieChart extends Chart

  render: (args) ->
    args = _.extend(@options, {
      popups: true
    }, args)
    super(args)

  generateSpec: (spec) ->
    spec = super(spec)
    _.extend({
      # Dimensions are necessary for pie charts to calculate the radius.
      width: 400
      height: 400
    }, spec)
    values = spec.values
    width = spec.width
    height = spec.height
    paddingForbody = spec.paddingForbody
    radius = spec.radius
    if !radius? && (width? || height?)
      radius = Math.min(height, width) / 2 - paddingForbody
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
    }, spec)
    if spec.labels
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
