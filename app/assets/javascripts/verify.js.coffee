###
verify.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

genie = exports? and @ or @genie = {}

class NavigationBar

  constructor: (bar, anchor) ->
    @ele = $ bar
    @top = $(anchor).offset().top

  stick: ->
    $(window).scroll =>
      if window.scrollY >= @top
        @ele.css 'top', 0
      else
        @ele.css 'top', '-50px'

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
          field = this.extract form
          field.removeClass 'error'
          field.addClass 'success'
        when false
          field = this.extract form
          field.removeClass 'success'
          field.addClass 'error'
        else
          for i, row of results
            for j, cell of row
              input = form.find "input[name='answer[#{i}][#{j}]']"
              (this.update input)(cell)
      null

  extract: (form) ->
    field = form.find 'input[name="answer"]'
    if field.length == 0 then form else field

init_scroll = ->
  problems = $('.lesson-problems')
  y = problems.offset().top
  w = problems.outerWidth()
  $(window).scroll ->
    if window.scrollY >= y
      problems.addClass 'sticky'
      problems.css 'width', w
    else
      problems.removeClass 'sticky'
      problems.css 'width', 'auto'
      w = problems.outerWidth()
  null

init_pagination = ->
  problems = $('.lesson-problems')
  nums     = problems.find('.pagination a[data-page]')
  ctrls    = problems.find('.pagination a[data-page-nav]')
  # TODO

  nums.click ->
    problems.find('.problem-wrapper:not(.hide)').addClass('hide')
    problems.find('#problem_' + $(this).data('page')).parent().removeClass('hide')
    problems.find('.pagination li.current a[data-page]').parent().removeClass('current')
    $(this).parent('li').addClass('current')
    false

@genie.init_problems = ->
  init_scroll()
  init_pagination()
  nav = new NavigationBar '.lesson-nav', 'section[role="lesson"]'
  nav.stick()

@genie.init_lesson = (options) ->
  answers = []
  answers[a.position] = a.content for a in options.answers
  for form, pos in options.forms
    problem = new Problem form, answers[pos]
    problem.observe()
  this.init_problems()
  null

# let all AJAX calls include CSRF token
$ ->
  $.ajaxSetup beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr 'content'
      xhr.setRequestHeader 'X-CSRF-Token', token
