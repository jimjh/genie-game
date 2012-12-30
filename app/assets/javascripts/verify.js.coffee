###
verify.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012 Jiunn Haur Lim, Carnegie Mellon University
License: https://raw.github.com/jimjh/genie-game/master/LICENSE
###

# TODO: refactor
genie = exports? and @ or @genie = {}

class Problem
  constructor: (button) ->
    @button = $ button

  # Adds click listeners to the submit buttons.
  observe: ->
    @button.click (e) =>
      form = @button.parents 'form'
      id = form.find('input.q-id').val();
      $.ajax
        type: 'POST'
        url: "verify/quiz/#{id}"
        data: form.serialize()
        success: this.update form
      false

  # Shows results of last submission at the given button and form.
  update: (form) ->
    (result) =>
      switch result
        when true
          form.removeClass 'error'
          form.addClass 'success'
        when false
          form.removeClass 'success'
          form.addClass 'error'
        else
          for i, row of result
            for j, cell of row
              input = form.find "input[name='answer[#{i}][#{j}]']"
              (this.update input)(cell)
      null

init = ->
  for button in $ 'a.button.submit'
    problem = new Problem button
    problem.observe()
  null

@genie.launch = ->
  init()
  $.ajaxSetup beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr 'content' ;
      xhr.setRequestHeader 'X-CSRF-Token', token ;

$ @genie.launch
