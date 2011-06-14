module Formitect
  # Base class for +Formitect+ form builders.
  class Base < ActionView::Helpers::FormBuilder
    helpers = field_helpers +
      %w(date_select datetime_select time_select collection_select) +
      %w(select country_select time_zone_select) -
      %w(label fields_for hidden_field)

    helpers.each do |name|
      define_method name do |field, *args|
        options = args.detect { |argument| argument.is_a?(Hash) } || {}
        build_shell(field, options) do
          super(field, *args)
        end
      end
    end

    def build_shell(field, options)
      raise 'You must implement the "build_shell" method in your form builder'
    end

    def label_text(field, text)
      result = label(field, text)
      return result unless required_field?(field)

      # Field is required so find the char index before the closing label tag
      # and insert the abbr tag.
      index = result.index('</label>')
      result.insert(index,
        @template.content_tag(:abbr, '*', :title => 'required'))
    end

    def error_message(field)
      return '' unless has_errors_on?(field)
      errors = object.errors[field]
      errors.is_a?(Array) ? errors.to_sentence : errors
    end

    def has_errors_on?(field)
      !(object.nil? || object.errors[field].blank?)
    end

    def required_field?(field)
      unless object.nil?
        object.class.validators_on(field).map(&:kind).include?(:presence)
      end
    end
  end
end
