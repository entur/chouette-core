module SimpleFormFormBuilderWithSafeSubmit
  def button(type, *args, &block)
    options = args.extract_options!.dup
    if type == :submit
      options[:data] ||= {}
      options[:data][:disable_with] ||= I18n.t('actions.wait_for_submission')
    end
    args << options
    super type, *args, &block
  end
end

::SimpleForm::FormBuilder.class_eval do
  prepend SimpleFormFormBuilderWithSafeSubmit
end
