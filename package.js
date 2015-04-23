// Meteor package definition.
Package.describe({
  name: 'aramk:vega-charts',
  version: '0.3.2',
  summary: 'Simple charting with Vega and D3.',
  git: 'https://github.com/aramk/vega-charts.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@0.9.0');
  api.use([
    'coffeescript',
    'jquery',
    'less',
    'templating',
    'underscore',
    'aramk:q@1.0.1',
    'aramk:utility@0.3.0',
    'aramk:vega@1.4.2_1'
    ],'client');
  api.imply('aramk:vega');
  // TODO(aramk) Perhaps expose the charts through the Vega object only to avoid cluttering the
  // namespace.
  api.export([
    'Vega', 'Chart', 'PieChart', 'LineChart'
  ], 'client');
  api.addFiles([
    'src/Vega.coffee',
    'src/charts/Chart.coffee',
    'src/charts/PieChart.coffee',
    'src/charts/LineChart.coffee',
    'src/chart.less',
    'src/meteor/chart.html',
    'src/meteor/chart.coffee'
  ], 'client');
});
