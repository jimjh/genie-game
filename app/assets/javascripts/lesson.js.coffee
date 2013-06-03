###
lesson.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

genie = exports? and @ or @genie = {}

class NavigationBar

  constructor: (opts) ->
    @ele = $ opts.bar
    @top = $(opts.anchor).offset().top - @ele.outerHeight()

  stick: ->
    $(window).scroll =>
      if window.scrollY >= @top
        @ele.css 'top', 0
      else
        @ele.css 'top', ''
    this

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
    @form.find('input[type="radio"]:checked').next('span.custom.radio').addClass 'checked'
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

  constructor: (opts) ->
    @window = $ opts.window
    @paginator = @window.find opts.paginator
    @top   = @window.offset().top
    @width = @window.outerWidth()

  scroll: ->
    $(window).scroll =>
      if window.scrollY >= @top - 56
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
        @window.find('.problem-wrapper:not(.hide)').addClass('hide')
        @window.find('#problem_' + (page - 1)).parent().removeClass('hide')
    this

@genie.init_lesson = (options) ->
  # init each problem
  answers = []
  answers[a.position] = a.content for a in options.answers
  for form, pos in options.problems
    problem = new Problem form, answers[pos]
    problem.observe()
  # init navigation bar
  nav = new NavigationBar options.navigation
  nav.stick()
  # init viewer
  viewer = new Viewer options.viewer
  viewer.scroll().paginate()
  null