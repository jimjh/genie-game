/* Global Angular App */
(function(angular) {
  'use strict';

  function setCSRFToken($httpProvider) {
    var token = $('meta[name="csrf-token"]').attr('content');
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = token;
  }

  window.app = angular.module('App', ['App.controllers', 'App.directives']).
    config(['$httpProvider', function($httpProvider) {
      setCSRFToken($httpProvider);
    }]);

})(angular);
