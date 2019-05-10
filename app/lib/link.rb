class Link
  attr_reader :content, :href, :method, :data, :extra_class, :disabled

  def initialize(content: nil, href:, method: nil, data: nil, extra_class: nil, disabled: false)
    @content = content
    @href = href
    @method = method
    @data = data
    @extra_class = extra_class
    @disabled = disabled
  end
end
