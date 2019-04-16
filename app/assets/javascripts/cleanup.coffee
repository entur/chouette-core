$(document).on("change", 'input[name="clean_up[date_type]"]', (e) ->
  type = $("[name='clean_up[date_type]']:checked").val()
  end_date = $('.cleanup_end_date_wrapper')

  end_date.toggle(type == 'between' || type == 'outside')

  $(".before, .after, .outside, .between").hide()
  $(".#{type}").show().removeClass('hidden')
)
