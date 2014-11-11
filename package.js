// Meteor package definition.
Package.describe({
  name: 'aramk:vega-charts',
  version: '0.1.0',
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
    'aramk:utility@0.3.0',
    'aramk:vega@1.4.2'
    ],'client');
  api.imply('aramk:vega');
  // TODO(aramk) Perhaps expose the charts through the Vega object only to avoid cluttering the
  // namespace.
  api.export([
    'Vega', 'PieChart'
  ], 'client');
  api.addFiles([
    'src/Vega.coffee',
    'src/PieChart.coffee',
    'src/chart.less',
    'src/meteor/pieChart.html',
    'src/meteor/pieChart.coffee',
  ], 'client');
});
