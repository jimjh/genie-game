/* Removes no-js from element */
(function(angular) {
  'use strict';

  function removeClass(scope, elem) {
    elem.removeClass('no-js');
  }

  angular.module('App.directives').
    directive('noJs', function() {
    return { restrict: 'A', link: removeClass };
  });

})(angular);
