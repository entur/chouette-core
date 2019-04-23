updateCleanUpForm = ->
  type = $("[name='clean_up[date_type]']:checked").val()
  end_date = $('.cleanup_end_date_wrapper')

  $(".before, .after, .outside, .between").hide()
  $(".#{type}").show().removeClass('hidden')


$(document).on "change", 'input[name="clean_up[date_type]"]', updateCleanUpForm
$ ->
  updateCleanUpForm()
