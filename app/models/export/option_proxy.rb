class Export::OptionProxy
  def initialize export, parent_option
    @export = export
    @parent_option = parent_option

    if parent_option[:collection].is_a?(Array)
      parent_option[:collection].each do |val|
        define_singleton_method val do |&block|
          @_collection_value = val
          instance_exec &block
          @_collection_value = nil
        end
      end
    end
  end

  def option name, opts={}
    opts.update depends: {option: @parent_option[:name], value: @_collection_value}, name: name
    @export.option "#{name}-#{@parent_option[:name]}-#{@_collection_value}", opts
  end
end
