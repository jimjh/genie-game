(function(angular) {
  'use strict';

  // Makes a GET request to retrieve the stats.
  function loadJSON($scope, $http, statsURL) {
    $http.get(statsURL).
      success(function(data) { $scope.stats = data; }).
      error(function() { /* TODO */ });
  }

  function StatsCtrl($scope, $http) {
    $scope.init = function(statsURL) {
      loadJSON($scope, $http, statsURL);
    };
  }

  angular.module('App.controllers').
    controller('StatsCtrl', ['$scope', '$http', StatsCtrl]);

})(angular);

