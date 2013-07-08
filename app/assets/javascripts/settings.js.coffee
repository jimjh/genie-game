###
settings.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

@genie = {} unless @genie?
genie = @genie

class RepoSwitch

  CODES:
    published:   'green'
    publishing:  'yellow'
    failed:      'red'
    deactivated: 'red'

  CLASSES: 'green yellow red hide'

  constructor: (form) ->
    @form = $ form

  observe: ->

    @form.bind 'ajax:success', (event, data, status, xhr) =>
      this.toggle_colors data.status
      this.update_id data.id if xhr.status == 201

    @form.bind 'ajax:error', (event, xhr) =>
      this.toggle_switch false
      errors = null
      try
        errors = $.parseJSON(xhr.responseText).errors
      catch SyntaxError
      finally
        this.update_errors errors

    # submit form when switch is clicked
    @form.find('input[type="radio"]').click =>
      @form.submit()
    this

  toggle_switch: (state) ->
    @form.find('input[value=off]').prop('checked', !state)
    @form.find('input[value=on]').prop('checked', state)

  toggle_colors: (status) ->
    lights = @form.closest('tr').find('.lesson-status')
    lights.removeClass(@CLASSES)
            .addClass(@CODES[status])  # update color class
    lights.find('span.has-tip')        # update tooltip text
            .attr('title', status.capitalize())
            .attr('data-selector', null)

  update_id: (id) ->
    input = $('<input>').attr
      name: 'id'
      type: 'hidden'
      value: id
    @form.append input

  update_errors: (errors) ->
    modal = $('#errors')
    ul    = modal.find('ul')
    if errors?
      messages = (field + ' ' + msg for msg in list for field, list of errors)
      messages = [].concat.apply [], messages
      ul.removeClass('hide').empty()
      ul.append($('<li>').html(msg)) for msg in messages
    else
      ul.addClass('hide')
    modal.foundation('reveal', 'open')

@genie.init_settings = (options) ->
  for form in options.switches
    s = new RepoSwitch form
    s.observe()
  null
