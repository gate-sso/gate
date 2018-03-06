# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

API_RESOURCE_NAME_FORMAT_ERROR_MSG = "Please enter valid name containing only alphanumeric (a-z, A-Z, 0-9), underscore (_) and dash (-)"
API_RESOURCE_NAME_UNIQUENESS_ERROR_MSG = "API name already taken"
API_RESOURCE_DESC_REQUIRED_ERROR_MSG = "Please enter description"

append_error_msg = (elem, res, msg) ->
  if !res
    elem.addClass('is-invalid')
    elem.next('.invalid-feedback').html(msg)
  else
    elem.removeClass('is-invalid')
    elem.next('.invalid-feedback').html('')

validate_required = (elem, msg) ->
  input = elem.val()
  append_error_msg(elem, input, msg)
  return !!input

validate_pattern = (elem, pattern, msg) ->
  input = elem.val()
  regex = new RegExp(pattern)
  validate_regex = regex.test(input)
  append_error_msg(elem, validate_regex, msg)
  return !!validate_regex

validate_uniqueness = (elem, check_url, msg) ->
  input = elem.val()
  $.ajax
    url: check_url + '?q=' + encodeURIComponent(input) + '&exact=true'
    type: 'GET'
    error: ->
      return
    success: (res) ->
      append_error_msg(elem, $.isEmptyObject(res), msg)
      return

api_resources_ready = ->
  $('#api_resource_name').on 'blur', ->
    valid = validate_pattern($('#api_resource_name'), '^[a-zA-Z0-9_-]+$', API_RESOURCE_NAME_FORMAT_ERROR_MSG)
    if valid 
      validate_uniqueness($('#api_resource_name'), '/api_resources/search', API_RESOURCE_NAME_UNIQUENESS_ERROR_MSG)

  $('#api_resource_description').on 'blur', ->
    validate_required($('#api_resource_description'), API_RESOURCE_DESC_REQUIRED_ERROR_MSG)

  $('#new_api_resource').submit (event) ->
    if $('.is-invalid').length > 0
      event.preventDefault()
      event.stopPropagation()
    return

$(document).on('turbolinks:load', api_resources_ready)
