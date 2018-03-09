# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

host_machines_ready = ->
  $('#group_id').selectize
    maxItems: 1
    valueField: 'id'
    labelField: 'name'
    searchField: 'name'
    create: false
    render: option: (item, escape) ->
      '<div>' + escape(item.name) + '</div>'
    load: (query, callback) ->
      if !query.length
        return callback()

      # Use remote as source
      $.ajax
        url: '/groups/search?q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#group_id').on 'change', ->
    set_allow_submit($(this).val(), $(this))

$(document).on('turbolinks:load', host_machines_ready)
