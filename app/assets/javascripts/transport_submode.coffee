@updateSubmdodeSelectOptions = ->
  $submodeSelect = $('.js-transport-submode-select')

  if $submodeSelect.length > 0
    updateSubmodeOptions = (mode) ->
      submodeOptions = $submodeSelect.data("transport-submodes")[mode]
      $submodeSelect.find('option').remove()
      if submodeOptions
        for option in submodeOptions
          $submodeSelect.append "<option value=#{option.value} #{ 'selected' if option.value is $submodeSelect.data("selected") }>#{option.label}</option>"
        $submodeSelect.parents('.form-group').show()
      else
        $submodeSelect.parents('.form-group').hide()

    $transportModeSelect = $('.js-transport-mode-select')

    updateSubmodeOptions($transportModeSelect.val())

    $transportModeSelect.change ->
      updateSubmodeOptions($(this).val())

@updateSubmodeCheckboxOptions = ->
  $transportModeCheckboxes = $('.js-transport-mode-checkboxes :checkbox')
  $submodeCheckboxes = $('.js-transport-submode-checkboxes :checkbox')

  if $transportModeCheckboxes.length > 0 && $submodeCheckboxes.length > 0

    updateSubmodeOptions = (event) ->
      numberOfModes = $transportModeCheckboxes.length

      if selectedModes.length == 0 || selectedModes.length == numberOfModes
        $submodeCheckboxes.attr('disabled', false)
      else
        selectedModes = $('.js-transport-mode-checkboxes :checked').map ->
          $(this).data('transport-mode')

        submodeOptions = Array.from(selectedModes).reduce ((acc, mode) ->
          options = $('.js-transport-submode-checkboxes').data('transport_submodes')[mode] || []
          acc.concat(options)
        ), []

        submodeOptions.forEach (option) ->
          $("[data-transport-submode=#{option['value']}]").attr('disabled', false) if option['value']

    $transportModeCheckboxes.change (e) ->
      $submodeCheckboxes.attr('disabled', true)
      updateSubmodeOptions(e)

$ ->
  updateSubmdodeSelectOptions()
  updateSubmodeCheckboxOptions()
