###
utils.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

# capitalizes a word
String::capitalize = -> @substr(0, 1).toUpperCase() + @substr(1)

# lets all AJAX calls include the CSRF token
includeCSRFToken = ->
  $.ajaxSetup beforeSend: (xhr) ->
    token = $('meta[name="csrf-token"]').attr 'content'
    xhr.setRequestHeader 'X-CSRF-Token', token

# sets Content-Type on XHR POST requests so Qt stops complaining
setContentType = ->
  $('a[data-remote="true"]').bind 'ajax:beforeSend', (event, xhr, settings) ->
    if settings.type == 'POST'
      xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'

$ ->
  includeCSRFToken()
  setContentType()
