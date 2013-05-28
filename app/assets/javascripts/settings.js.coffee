###
settings.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

class RepoSwitch

  CODES:
    published: 'green'
    publishing: 'yellow'
    failed: 'red'
    deactivated: 'red'

  CLASSES: 'green yellow red hide'

  constructor: (form) ->
    @form = $ form

  observe: ->
    @form.bind 'ajax:success', (event, data, status, xhr) =>
      lights = @form.closest('tr').find('.lesson-status')
      lights.removeClass(@CLASSES)
              .addClass(@CODES[data.status])  # update color class
      lights.find('span.has-tip')             # update tooltip text
              .attr('title', data.status.capitalize())
              .attr('data-selector', null)
      if (xhr.status == 201)                  # add hidden input field for ID
        input = $('<input>').attr
          name: 'id'
          type: 'hidden'
          value: data.id
        @form.append input

    # submit form when switch is clicked
    @form.find('input[type="radio"]').click =>
      @form.submit()
    this

@genie.init_settings = (options) ->
  for form in options.switches
    s = new RepoSwitch form
    s.observe()
  null
