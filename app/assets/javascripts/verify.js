/* ========================================================================
 * verify.js
 * http://github.com/jimjh/genie-game
 * ========================================================================
 * Copyright (c) 2012 Jiunn Haur Lim, Carnegie Mellon University
 * License: https://raw.github.com/jimjh/genie-game/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global $*/

;(function () {
  'use strict';

  // TODO: refactor

  // Shows results of last submission at the given button and form.
  var showResult = function(form) {
    return function(result) {
      switch(result) {
      case true:
        form.removeClass('error');
        form.addClass('success');
        break;
      case false:
        form.removeClass('success');
        form.addClass('error');
        break;
      default:
        $.each(result, function(i, row) {
          $.each(row, function(j, cell) {
            var input = form.find("input[name='answer["+i+"]["+j+"]']");
            showResult(input)(cell);
          });
        });
      }
    };
  };

  // Adds click listeners to the submit buttons.
  var observeSubmitButton = function() {

    $('a.button.submit').click(function(e) {
      var button = $(e.target);
      var form = button.parents('form');
      var id = form.find('input.q-id').val();
      $.ajax({
        type: 'POST',
        url: 'verify/quiz/' + id,
        data: form.serialize(),
        success: showResult(form)
      });
      return false;
    });

  };

  // Adds click listeners to the run buttons.
  // var run = function() {
  //   $('a.button.run').click(function(e){
  //     var form = $(e.target).parents('form');
  //     var raw = form.find('.ex-raw').val();
  //     var id = form.find('.ex-id').val();
  //     $.post('/verify/code/' + id, raw,
  //       function(data) { console.log(data); }
  //     );
  //     return false;
  //   });
  // };

  var genie = {

    launch: function() {
      observeSubmitButton();
    }

  };

  $.ajaxSetup({
    beforeSend: function(xhr) {
      var token = $('meta[name="csrf-token"]').attr('content');
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });

  $(genie.launch());

})();
