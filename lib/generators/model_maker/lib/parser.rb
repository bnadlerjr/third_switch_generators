class SQSParser
  attr_reader :tables

  def initialize(file_name)
    @doc = Nokogiri::XML(File.read(file_name))
    @tables = @doc.xpath('//SQLTable').map { |t| Table.new(t) }

    create_has_many_associations
    create_belongs_to_associations
  end

  private

  def create_has_many_associations
    @doc.xpath('//SQLField[name="id"]').each do |node|
      model_name = node.parent.xpath('name').text.underscore.singularize
      if index = find_table_index_by_name(model_name)
        node.xpath('referencesTable').each do |ref|
          @tables[index].add_association(:has_many, ref.text.underscore)
        end
      end
    end
  end

  def create_belongs_to_associations
    @doc.xpath('//SQLField').each do |node|
      if node.xpath('name').text =~ /\w+_id/
        model_name = node.parent.xpath('name').text.underscore.singularize
        if index = find_table_index_by_name(model_name)
          @tables[index].add_association(:belongs_to,
            node.xpath('name').text.split('_')[0])
        end
      end
    end
  end

  def find_table_index_by_name(name)
    @tables.index { |t| t.model_name == name }
  end

  class Table
    def initialize(table_node)
      @table_node = table_node
      @associations = Hash.new { |hash, key| hash[key] = [] }
      @validations = create_validations
    end

    def model_name
      @model_name ||= @table_node.xpath('name').text.underscore.singularize
    end

    def model_generation_args
      @model_generation_args ||= @table_node.xpath('SQLField').map do |f|
        unless (name = f.xpath('name').text) == 'id'
          "#{name}:#{f.xpath('type').text}"
        end
      end.compact!.join(' ')
    end

    def add_association(type, table_name)
      unless @associations[type].include?(table_name)
        @associations[type] << table_name
      end
    end

    def association_block
      @associations.map do |k, v|
        v.map { |assoc| "  #{k} :#{assoc}\n" }
        #"  #{k} #{v.map { |r| ":#{r}" }.join(', ')}" unless v.empty?
      end.join("\n")
    end

    def validation_block
      "\n" + @validations.map do |k, v|
        "  #{k} #{v.map { |r| ":#{r}" }.join(', ')}" unless v.empty?
      end.join("\n") + "\n"
    end

    private

    def create_validations
      validations = Hash.new { |hash, key| hash[key] = [] }
      @table_node.xpath('SQLField[notNull="1"]').each do |f|
        name = f.xpath('name').text
        unless name == 'id' || name =~ /\w+_id/
          validations[:validates_presence_of] << name
        end
      end

      validations
    end
  end
end
