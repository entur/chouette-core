@selectTable = ->
  $('.select_table').each ->
    selection = []
    toolbox = $(this).children('.select_toolbox')

    $(this).on 'click', "[type='checkbox']", (e)->
      if e.currentTarget.id == '0'
        selection = []
        if e.currentTarget.checked
          $(this).closest('.table').find("[type='checkbox']").each ->
            unless $(this).attr('disabled')
              $(this).prop('checked', true)
              # Add each element to selection
              selection.push($(this).attr('id'))

          # Remove th checkbox from selection
          selection.splice(0, 1)

        else
          $(this).closest('.table').find("[type='checkbox']").each ->
            $(this).prop('checked', false)
          # Empty selection
          selection = []

      else
        if e.currentTarget.checked
          selection.push(e.currentTarget.id)
        else
          elm = selection.indexOf(e.currentTarget.id)
          selection.splice(elm, 1)

      # console.log(selection)

      # Updating toolbox, according to selection
      if selection.length > 0
        toolbox
          .removeClass 'noselect'
          .children('.info-msg').children('span').text(selection.length)

        # Injecting selection into action urls
        toolbox.find('.st_action').each ->
          actionURL = $(this).children('a').attr('data-path')

          newSelection = []
          i = 0
          while i < selection.length
            newSelection[i] = 'referentials[]=' + selection[i] + ''
            i++

          $(this).children('a').attr('href', actionURL + '?' + newSelection.join('&'))

      else
        toolbox
          .addClass 'noselect'
          .children('.info-msg').children('span').text(selection.length)

$ ->
  selectTable()
