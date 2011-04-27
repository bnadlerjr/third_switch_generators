module OmniAuth
  class UserGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_model
      generate 'model', 'user provider:string uid:string name:string --no-migration'
    end

    def create_migration
      copy_file "migration.rb", "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_create_users.rb"
    end

    def add_validations_to_model
      insert_into_file 'app/models/user.rb', :after => "class User < ActiveRecord::Base\n" do
        <<-RUBY
  validates :name,     :presence => true
  validates :provider, :presence => true
  validates :uid,      :presence => true,
                       :uniqueness => true
        RUBY
      end
    end
  end
end
