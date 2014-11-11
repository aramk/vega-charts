Vega =

  # Renders the given spec in the given element.
  # @param {Object|String} spec - The Vega spec in JSON format or a URL.
  # @param {jQuery|HTMLElement} el - The HTML element to render the chart in.
  # @param {Object} [options]
  # @param {Boolean} [options.resize=false] - Whether to resize the chart based on the dimensions of
  # the given HTML element. This overrides the height and width set in the spec.
  # @returns {Promise}
  render: (spec, el, options) ->
    options = _.extend({
      resize: false
    }, options)
    df = Q.defer()
    $el = $(el)
    @getSpec(spec).then(
      (spec) ->
        if options.resize
          padding = _.extend({top: 0, bottom: left: 0, right: 0}, spec.padding)
          spec.width = $el.width() - padding.left - padding.right
          spec.height = $el.height() - padding.top - padding.bottom
        vg.parse.spec spec, (chart) ->
          view = chart(el: $el[0]).update()
          df.resolve(chart: chart, view: view)
      df.reject
    )
    df.promise

  # @param {Object|String} spec - The Vega spec in JSON format or a URL.
  # @returns {Promise} A promise containing the Vega spec in JSON format.
  getSpec: (spec) ->
    if Types.isString(spec)
      specDf = @requestSpec(spec)
    else
      specDf = Q.defer()
      specDf.resolve(spec)
    specDf.promise

  # @param {String} url - The URL to the Vega spec.
  # @returns {Promise} A promise containing the Vega spec in JSON format.
  requestSpec: (url) -> $.getJSON(url)
