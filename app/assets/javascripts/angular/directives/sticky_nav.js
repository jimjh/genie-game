(function(angular) {
  'use strict';

  if (typeof angular === 'undefined') {
    throw new ReferenceError('angular is undefined');
  }

  /**
   * Makes a sub-nav sticky.
   * @example
   *  <dl class='sub-nav' data-sticky-nav='.anchor.selector'></dl>
   */
  function StickyNavDirective($window) {

    function stick(scope, elem, attrs) {

      var anchor = angular.element(attrs.stickyNav),
          top    = anchor.offset().top - elem.outerHeight();

      var window = angular.element($window);
      window.bind("scroll", function() {
        if(this.scrollY >= top) { elem.css('top', 0); }
        else { elem.css('top', ''); }
      });

    }

    return { restrict: 'A', link: stick };

  }

  angular.module('App.directives').
    directive('stickyNav', ['$window', StickyNavDirective]);

})(angular);
