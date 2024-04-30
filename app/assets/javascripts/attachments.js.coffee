
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#attachment_uploaded_file').attr('name','attachment[uploaded_file]')
  $('#new_attachment').fileupload
    dataType: 'script'
    add: (e, data) ->
      file = data.files[0]
      data.context = $(tmpl("template-attachment", file))
      $('#new_attachment').append(data.context)
      data.submit()
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
