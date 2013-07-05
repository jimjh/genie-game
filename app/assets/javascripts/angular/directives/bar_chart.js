/* Builds a HighCart chart. */
(function(angular) {
  'use strict';

  function render(elem, stats) {
    elem.highcharts({
      chart: { type: 'bar' },
      title: { text: 'Problem Difficulty' },
      xAxis: {
        categories: $.map(stats, function(s) { return s.n; }),
        title: { text: 'Problem #' }
      },
      yAxis: {
        title: { text: 'Avg. Number of Incorrect Attempts' },
      },
      series: [{
        name: 'Attempts',
        data: $.map(stats, function(s) { return s.avgAttempts; })
      }]
    });
  }

  /* Assumes parent scope has a 'stats' field. */
  function buildChart(scope, elem) {
    scope.$watch('stats', function(stats) {
      if (angular.isUndefined(stats)) { return; }
      render(elem, stats);
    });
  }

  angular.module('App.directives').
    directive('barChart', function() {
    return {
      link: buildChart,
      restrict: 'E',
      replace: true,
      template: '<div></div>'
    };
  });

})(angular);

