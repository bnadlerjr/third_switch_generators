require File.expand_path('../lib/parser', __FILE__)

class ModelMakerGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :file_path

  def parse_file
    @tables = SQSParser.new(file_path).tables
  end

  def generate_models
    @tables.each do |t|
      say "Generating model #{t.model_name} #{t.model_generation_args}"
      generate("model", "#{t.model_name} #{t.model_generation_args}")
    end
  end

  def add_associations
    @tables.each do |t|
      say t.model_name
      say t.association_block
      insert_into_file "app/models/#{t.model_name}.rb",
        t.association_block, :before => 'end'
    end
  end

  def add_validations
    @tables.each do |t|
      say t.model_name
      say t.validation_block
      insert_into_file "app/models/#{t.model_name}.rb",
        t.validation_block, :before => 'end'
    end
  end

  #   create the tests for the model validations
end
