module IconHelper

  def fa_icon(names = "flag", options = {})
    classes = ["fa"]
    classes.concat Private.icon_names(names)
    classes.concat Array(options.delete(:class))
    text = options.delete(:text)
    right_icon = options.delete(:right)
    icon = content_tag(:i, nil, options.merge(:class => classes))
    Private.icon_join(icon, text, right_icon)
  end

  def fa_stacked_icon(names = "flag", options = {})
    classes = Private.icon_names("stack").concat(Array(options.delete(:class)))
    base_names = Private.array_value(options.delete(:base) || "square-o").push("stack-2x")
    names = Private.array_value(names).push("stack-1x")
    base = fa_icon(base_names, options.delete(:base_options) || {})
    icon = fa_icon(names, options.delete(:icon_options) || {})
    icons = [base, icon]
    icons.reverse! if options.delete(:reverse)
    text = options.delete(:text)
    right_icon = options.delete(:right)
    stacked_icon = content_tag(:span, safe_join(icons), options.merge(:class => classes))
    Private.icon_join(stacked_icon, text, right_icon)
  end

  def boolean_icon val
    icon = val ? 'check' : 'times'
    txt = fa_icon(icon) + (val ? 'true'.t : 'false'.t)
    "<span class='boolean-icon #{val}'>#{txt}</span>".html_safe
  end

  def render_icon(klass, title, style='')
    content_tag :span, '',
      class: klass,
      style: "margin-right:5px; font-weight: 600; #{style}",
      title: title
  end

  def color_icon(color)
    painted_color = color.presence || 'FFFFFF'
    displayed_color = color.present? ? "##{color}" : '-'
    content_tag(:i, nil, class: 'fa fa-square fa-lg', style:"color:##{painted_color}") + " #{displayed_color}"
  end

  module Private
    extend ActionView::Helpers::OutputSafetyHelper

    def self.icon_join(icon, text, reverse_order = false)
      return icon if text.blank?
      elements = [icon, ERB::Util.html_escape(text)]
      elements.reverse! if reverse_order
      safe_join(elements, " ")
    end

    def self.icon_names(names = [])
      array_value(names).map { |n| "fa-#{n}" }
    end

    def self.array_value(value = [])
      value.is_a?(Array) ? value : value.to_s.split(/\s+/)
    end
  end
end
