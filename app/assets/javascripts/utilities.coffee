# Utility functions

@append_error_msg = (elem, res, msg) ->
  if !res
    elem.addClass('is-invalid')
    elem.next('.invalid-feedback').html(msg)
  else
    elem.removeClass('is-invalid')
    elem.next('.invalid-feedback').html('')

@validate_required = (elem, msg) ->
  input = elem.val()
  append_error_msg(elem, input, msg)
  return !!input

@validate_pattern = (elem, pattern, msg) ->
  input = elem.val()
  regex = new RegExp(pattern)
  validate_regex = regex.test(input)
  append_error_msg(elem, validate_regex, msg)
  return !!validate_regex

@validate_uniqueness = (elem, check_url, msg) ->
  input = elem.val()
  $.ajax
    url: check_url + '?q=' + encodeURIComponent(input) + '&exact=true'
    type: 'GET'
    error: ->
      return
    success: (res) ->
      append_error_msg(elem, $.isEmptyObject(res), msg)
      return
