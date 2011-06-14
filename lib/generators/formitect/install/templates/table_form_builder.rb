require File.expand_path('../base', __FILE__)

class TableFormBuilder < Formitect::Base
  def submit(field, *args)
    options = args.detect { |arg| arg.is_a?(Hash) } || {}
    options[:label] = '&nbsp;'
    build_shell(field, options) do
      super(field, *args)
    end
  end

  def build_shell(field, options)
    label = options[:label] == '&nbsp;' ? nil : label_text(field, options[:label])

    th = @template.content_tag(:th, label)
    td = @template.content_tag(:td, yield)
    @template.content_tag(:tr, th + td)
  end
end
