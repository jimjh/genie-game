###
verify.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012 Jiunn Haur Lim, Carnegie Mellon University
###

genie = exports? and @ or @genie = {}

class Problem
  constructor: (button) ->
    @button = $ button

  # Adds click listeners to the submit buttons.
  observe: ->
    @button.click (e) =>
      this.submit @button.parents 'form'
      false

  # Submits form for verification
  submit: (form) ->
    $.ajax
      type: 'POST'
      url: form.attr 'action'
      data: form.serialize()
      success: this.update form

  # Shows results of last submission at the given button and form.
  # TODO: refactor
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
      token = $('meta[name="csrf-token"]').attr 'content'
      xhr.setRequestHeader 'X-CSRF-Token', token

$ @genie.launch
