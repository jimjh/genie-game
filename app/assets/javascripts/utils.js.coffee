###
utils.js
http://github.com/jimjh/genie-game
===
Copyright (c) 2012-2013 Jiunn Haur Lim, Carnegie Mellon University
###

# capitalize a word
String::capitalize = -> @substr(0, 1).toUpperCase() + @substr(1)

# let all AJAX calls include CSRF token
$ ->
  $.ajaxSetup beforeSend: (xhr) ->
      token = $('meta[name="csrf-token"]').attr 'content'
      xhr.setRequestHeader 'X-CSRF-Token', token

