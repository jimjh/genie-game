/* Binds a TTY object */
(function(angular, tty) {
  'use strict';

  function TTYDirective($http) {

    var URL = '/terminals';

    function httpError() {
      // TODO
    }

    function httpSuccess(elem) {
      return function(data) {
        tty.open(data.user_id);
        var win = new tty.Window(elem[0]);
        win.tabs[0].ready(data.terminal_id);
      };
    }

    function buildTTY(scope, elem) {
      $http.post(URL).
        success(httpSuccess(elem)).
        error(httpError);
    }

    return {
      restrict: 'A',
      scope: true,
      link: buildTTY
    };

  }

  angular.module('App.directives').
    directive('tty', TTYDirective);

})(angular, tty);
