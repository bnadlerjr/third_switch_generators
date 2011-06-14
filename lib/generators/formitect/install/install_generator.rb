module Formitect
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def formitect_initializer
      initializer('formitect.rb') do
        <<-RUBY
require "#{Rails.root}/lib/formitect/template_form_builder"
require "#{Rails.root}/lib/formitect/table_form_builder"
RUBY
      end

      say 'Formitect initializer created... ' +
        'you may need to restart your server for it to take effect.', :red
    end

    def form_builders
      %w[base.rb template_form_builder.rb table_form_builder.rb].each do |f|
        copy_file f, "lib/formitect/#{f}"
      end
    end

    def field_template_views
      %w[_field.html.haml _field_with_errors.html.haml].each do |f|
        copy_file f, "app/views/shared/formitect/#{f}"
      end
    end

    def custom_form_helpers
      helpers = find_in_source_paths('application_helpers.rb')
      insert_into_file 'app/helpers/application_helper.rb',
        File.read(helpers), :after => "module ApplicationHelper\n"
    end
  end
end
