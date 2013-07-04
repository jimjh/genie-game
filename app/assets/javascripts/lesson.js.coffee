###
lesson.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

@genie = {} unless @genie?
genie = @genie

class Lesson
  SELECTOR: 'section[role="lesson"]'

class Problem

  SELECTOR:  Lesson::SELECTOR + ' form.problem'

  @prepare: (opts) ->
    problems = $ Problem::SELECTOR
    for form, pos in problems
      problem = new Problem $(form), opts.answers[pos], opts.lesson
      problem.observe()

  constructor: (@form, @answer, @lesson) ->
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
    @form.find('input[type="radio"]:checked').next('span.custom.radio').addClass 'checked'
    input = $('<input>').attr
      type: 'hidden'
      name: 'lesson_id'
      value: @lesson
    @form.append(input).submit (e) =>
      this.submit()
      false

  # Submits form for verification
  submit: =>
    $.ajax
      type: 'POST'
      url:  '/answers'
      data: @form.serialize()
      success: (answer) => (this.update @form)(answer.results)
      error: => (this.update @form)(false)

  # Shows results of last submission at the given form.
  # TODO: refactor
  update: (form) ->
    (results) =>
      switch results
        when true, false
          this.toggle form, results
        else
          for i, row of results
            for j, cell of row
              input = form.find "input[name='answer[#{i}][#{j}]']"
              (this.update input)(cell)
      null

  toggle:  (form, result) ->
    field = this.extract form
    field.removeClass 'success error'
    buttons = field.filter 'span.custom.radio.checked'
    if buttons.length == 0
      field.toggleClass 'success', result
      field.toggleClass 'error', !result
    else
      buttons.toggleClass 'success', result
      buttons.toggleClass 'error',   !result

  extract: (form) ->
    field = form.find 'input[name="answer"], span.custom.radio'
    if field.length == 0 then form else field

class Viewer

  WINDOW_SELECTOR:    Lesson::SELECTOR + ' .lesson-problems'
  PAGINATOR_SELECTOR: Viewer::WINDOW_SELECTOR + ' .jqpagination'
  PROBLEM_PREFIX:     '#problem_'
  PROBLEM_WRAPPER:    '.problem-wrapper'

  constructor: (opts) ->
    @window    = opts.window
    @paginator = opts.paginator
    @top   = @window.offset().top
    @width = @window.outerWidth()

  spy: ->
    $(window).scroll =>
      return unless $('[name=locked_to_text]').prop('checked')
      scrollTop = $(window).scrollTop()
      maxPage   = 1
      $('[data-pagination-destination]').each ->
        destination = $ this
        destPage    = Number destination.data 'pagination-destination'
        topOffset   = destination.offset().top - scrollTop
        maxPage     = destPage if topOffset < 0 and destPage > maxPage
      @paginator.data('jqPagination').setPage maxPage
    this

  stick: ->
    $(window).scroll =>
      scrollTop = $(window).scrollTop()
      if scrollTop >= @top - 56
        @window.addClass 'sticky'
        @window.css 'width', @width
      else
        @window.removeClass 'sticky'
        @window.css 'width', ''
        @width = @window.outerWidth()
    this

  paginate: ->
    @paginator.jqPagination
      page_string: 'Problem {current_page} of {max_page}'
      paged: (page) =>
        @window.find("#{Viewer::PROBLEM_WRAPPER}:not(.hide)")
          .addClass('hide')
        @window.find(Viewer::PROBLEM_PREFIX + (page - 1))
          .parent()
          .removeClass('hide')
    this

  @prepare: ->
    window    = $ Viewer::WINDOW_SELECTOR
    paginator = $ Viewer::PAGINATOR_SELECTOR
    viewer = new Viewer window: window, paginator: paginator
    viewer.stick().paginate().spy()

@genie.init_lesson = (options) ->
  answers = []
  answers[a.position] = a.content for a in options.answers
  Problem.prepare answers: answers, lesson: options.lesson
  Viewer.prepare()
