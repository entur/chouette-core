//= require 'plugins/bootstrap-colorpicker.min'

class ColorPicker
  constructor: (@element)->
    @textInput = @element.find('.hexInput')
    @textInput.on('change input', @onInputColorChanged)
    @element.colorpicker({ customClass: 'colorpicker-1-5x', align: 'left', sliders: {
                saturation: {
                    maxLeft: 200,
                    maxTop: 200
                },
                hue: {
                    maxTop: 200
                },
                alpha: {
                    maxTop: 200
                }
            }
        })

  onInputColorChanged: (event) =>
    @textInput.val(@formatToHexValue(@textInput.val()))

  formatToHexValue: (value) =>
    value.toUpperCase().replace(/[^A-F0-9]/g, '').slice(0,6) if value?

$ ->
  $('.enhanced_color_picker').each (index, element) ->
    new ColorPicker($(element))
