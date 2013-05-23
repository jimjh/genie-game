###
verify.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

genie = exports? and @ or @genie = {}

class Problem
  constructor: (form, @answer) ->
    @form = $ form
    this.preload() if @answer?

  preload: ->
    switch $.type @answer
      when 'string', 'number'
        @form.find("input[name='answer']:not([type='radio'])").val @answer
        @form.find("input[name='answer'][type='radio'][value='#{@answer}']").attr('checked', 'checked')
      else
        for i, row of @answer
          for j, cell of row
            input = @form.find "input[name='answer[#{i}][#{j}]']"
            input.val(cell) if input? and cell?


  # Adds click listeners to the submit forms.
  observe: ->
    @form.submit (e) =>
      this.submit()
      false

  # Submits form for verification
  submit: =>
    $.ajax
      type: 'POST'
      url: @form.attr 'action'
      data: @form.serialize()
      success: (answer) => (this.update @form)(answer.results)

  # Shows results of last submission at the given form.
  # TODO: refactor
  update: (form) ->
    (results) =>
      switch results
        when true
          field = form.find 'input[name="answer"]'
          field.removeClass 'error'
          field.addClass 'success'
        when false
          field = form.find 'input[name="answer"]'
          field.removeClass 'success'
          field.addClass 'error'
        else
          for i, row of results
            for j, cell of row
              input = form.find "input[name='answer[#{i}][#{j}]']"
              (this.update input)(cell)
      null

@genie.init_lesson = (options) ->
  answers = []
  answers[a.position] = a.content for a in options.answers
  for form, pos in options.forms
    problem = new Problem form, answers[pos]
    problem.observe()
  null

@genie.launch = ->
  $.ajaxSetup beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr 'content'
      xhr.setRequestHeader 'X-CSRF-Token', token

$ @genie.launch
