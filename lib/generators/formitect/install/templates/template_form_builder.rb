require File.expand_path('../base', __FILE__)

class TemplateFormBuilder < Formitect::Base
  def build_shell(field, options)
    @template.capture do
      options.merge!(:class => 'required') if required_field?(field)
      locals = {
        :element => yield,
        :desc    => '',
        :label   => label_text(field, options[:label])
      }

      if has_errors_on?(field)
        locals.merge!(:error => error_message(field))
        @template.render :partial => 'shared/formitect/field_with_errors',
          :locals => locals
      else
        @template.render :partial => 'shared/formitect/field',
          :locals => locals
      end
    end
  end
end
