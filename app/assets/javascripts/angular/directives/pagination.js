(function(angular) {
  'use strict';

  if (typeof angular === 'undefined') {
    throw new ReferenceError('angular is undefined');
  }

  /**
   * Enables jqPagination with scroll spy
   * @example
   *  <div data-pagination>
   *    <!-- jqPagination structure -->
   *  </div>
   */
  function PaginationDirective($window) {

    function paginate(scope, viewer, attrs) {

      var paginator = viewer.find(attrs.pagination),
          lock      = viewer.find('[name=pagination_locked_to_text]');

      paginator.jqPagination({
        page_string: 'Problem {current_page} of {max_page}',
        paged: function(page) {
          scope.$apply(function() { scope.currentPage = page + ''; });
        }
      });

      var window = angular.element($window);
      window.bind('scroll', function() {
        if(!lock.prop('checked')) { return; }
        var scrollTop = window.scrollTop(),
            maxPage   = 1;
        $('[data-pagination-destination]').each(function() {
          var destination = angular.element(this),
              destPage    = Number(destination.data('pagination-destination')),
              topOffset   = destination.offset().top - scrollTop;
          if(topOffset < 0 && destPage > maxPage) { maxPage = destPage; }
        });
        paginator.data('jqPagination').setPage(maxPage);
      });

    }

    return {
      restrict: 'A',
      link: paginate,
      scope: { currentPage: '@' },
    };

  }

  angular.module('App.directives').
    directive('pagination', ['$window', PaginationDirective]);

})(angular);
