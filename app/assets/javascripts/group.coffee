# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

group_ready = ->
  $('#assign_admin_user_id').selectize
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
      email = $('#server-vars').data('email')
      access_token = $('#server-vars').data('token')
      $.ajax
        url: '/api/v1/users/search?email=' + encodeURIComponent(email) + '&access_token=' + encodeURIComponent(access_token) + '&q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_user_user_id').selectize
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
      email = $('#server-vars').data('email')
      access_token = $('#server-vars').data('token')
      $.ajax
        url: '/api/v1/users/search?email=' + encodeURIComponent(email) + '&access_token=' + encodeURIComponent(access_token) + '&q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_vpn_vpn_id').selectize
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
      email = $('#server-vars').data('email')
      access_token = $('#server-vars').data('token')
      $.ajax
        url: '/api/v1/vpns/search?email=' + encodeURIComponent(email) + '&access_token=' + encodeURIComponent(access_token) + '&q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_machine_machine_id').selectize
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
      email = $('#server-vars').data('email')
      access_token = $('#server-vars').data('token')
      $.ajax
        url: '/api/v1/hosts/search?email=' + encodeURIComponent(email) + '&access_token=' + encodeURIComponent(access_token) + '&q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

$(document).on('turbolinks:load', group_ready)
