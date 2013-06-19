(function(angular, tty) {
  'use strict';

  if (typeof angular === 'undefined') {
    throw new ReferenceError('angular is undefined');
  }

  if (angular.isUndefined(tty)) {
    throw new ReferenceError('tty is undefined');
  }

  /**
   * Binds a TTY object
   * @example
   *  <div data-tty></div>
   */
  function TTYDirective($http) {

    var URL = '/terminals';

    function httpError(win) {
      return function() {
        win.tabs[0].disconnected();
      }
    }

    function httpSuccess(win) {
      return function(data) {
        win.tabs[0].ready(data.terminal_id);
      };
    }

    function buildTTY(scope, elem, attrs) {
      tty.open(attrs.userId);
      var win = new tty.Window(elem[0]);
      $http.post(URL).
        success(httpSuccess(win)).
        error(httpError(win));
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
