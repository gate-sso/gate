# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

API_RESOURCE_NAME_FORMAT_ERROR_MSG = "Please enter valid name containing only alphanumeric (a-z, A-Z, 0-9), underscore (_) and dash (-)"
API_RESOURCE_NAME_UNIQUENESS_ERROR_MSG = "API name already taken"
API_RESOURCE_DESC_REQUIRED_ERROR_MSG = "Please enter description"

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
