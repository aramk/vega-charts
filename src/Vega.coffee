Vega =

  # Renders the given spec in the given element.
  # @param {Object|String} spec - The Vega spec in JSON format or a URL.
  # @param {jQuery|HTMLElement} el - The HTML element to render the chart in.
  # @param {Object} [options]
  # @returns {Promise}
  render: (spec, el, options) ->
    options = _.extend({
      resize: false
    }, options)
    df = Q.defer()
    @getSpec(spec).then(
      (spec) ->
        vg.parse.spec spec, (chart) ->
          view = chart(el: $(el)[0]).update()
          df.resolve(chart: chart, view: view)
      df.reject
    )
    df.promise

  # @param {Object|String} spec - The Vega spec in JSON format or a URL.
  # @returns {Promise} A promise containing the Vega spec in JSON format.
  getSpec: (spec) ->
    if Types.isString(spec)
      @requestSpec(spec)
    else
      specDf = Q.defer()
      specDf.resolve(spec)
      specDf.promise

  # @param {String} url - The URL to the Vega spec.
  # @returns {Promise} A promise containing the Vega spec in JSON format.
  requestSpec: (url) ->
    df = Q.defer()
    $.getJSON(url).then(df.resolve, df.reject)
    df.promise
