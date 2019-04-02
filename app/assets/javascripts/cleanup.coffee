$(document).on("change", 'input[name="clean_up[date_type]"]', (e) ->
  type = $("[name='clean_up[date_type]']:checked").val()
  end_date = $('.cleanup_end_date_wrapper')

  if type == 'before'
    end_date.hide()
    $('span.begin_date').addClass 'hidden'
    $('span.end_date').removeClass 'hidden'

  else if type == 'after'
    end_date.hide()
    $('span.begin_date').removeClass 'hidden'
    $('span.end_date').addClass 'hidden'

  else
    $('span.begin_date').removeClass 'hidden'
    $('span.end_date').addClass 'hidden'
    end_date.show()
)
