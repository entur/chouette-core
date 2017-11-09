module TransportModeHelper
  def transport_mode_text(transport_modable=nil)
    mode    = transport_modable.try(:transport_mode)
    return "[Tous les modes de transport]" if mode.blank?

    submode = transport_modable.try(:transport_submode)
    [translated_mode_name(:mode, mode), translated_mode_name(:submode, submode)].join
  end

  private
  def translated_mode_name mode_type, value
    return "" if value.blank?
    "[#{t("enumerize.transport_#{mode_type}.#{value}")}]"
  end

end
