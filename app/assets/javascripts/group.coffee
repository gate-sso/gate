# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

group_ready = ->
  $('#assign_admin_user_id').selectize
    maxItems: 1
    valueField: 'id'
    labelField: 'name'
    searchField: 'name_email'
    create: false
    render: option: (item, escape) ->
      '<div>' + escape(item.name) + '<br /><span class=\'small\'>' + escape(item.email) + '</span></div>'
    load: (query, callback) ->
      if !query.length
        return callback()

      # Use remote as source
      $.ajax
        url: '/users/search?q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#assign_admin_user_id').on 'change', ->
    set_allow_submit($(this).val(), $(this))

  $('#add_user_user_id').selectize
    maxItems: 1
    valueField: 'id'
    labelField: 'name'
    searchField: 'name_email'
    create: false
    render: option: (item, escape) ->
      '<div>' + escape(item.name) + '<br /><span class=\'small\'>' + escape(item.email) + '</span></div>'
    load: (query, callback) ->
      if !query.length
        return callback()

      # Use remote as source
      $.ajax
        url: '/users/search?q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_user_user_id').on 'change', ->
    set_allow_submit($(this).val(), $(this))

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
      $.ajax
        url: '/vpns/search?q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_vpn_vpn_id').on 'change', ->
    set_allow_submit($(this).val(), $(this))

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
      $.ajax
        url: '/host_machines/search?q=' + encodeURIComponent(query) 
        type: 'GET'
        error: ->
          callback()
          return
        success: (res) ->
          callback res
          return
      return

  $('#add_machine_machine_id').on 'change', ->
    set_allow_submit($(this).val(), $(this))

$(document).on('turbolinks:load', group_ready)
