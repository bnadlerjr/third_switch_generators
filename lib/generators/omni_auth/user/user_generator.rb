module OmniAuth
  class UserGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def create_model
      generate 'model', 'user provider:string uid:string name:string --no-migration --no-fixture'
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

    def omniauth_creator_method
      insert_into_file 'app/models/user.rb', :after => ":uniqueness => true\n" do
        <<-RUBY
  # Creates a new user instance from an OmniAuth hash object.
  def self.create_from_omniauth_hash(auth_hash)
    create! do |user|
      user.name     = auth_hash["user_info"]["name"]
      user.provider = auth_hash["provider"]
      user.uid      = auth_hash["uid"]
    end
  end
        RUBY
      end
    end

    def create_user_factory
      copy_file "user_factory.rb", "test/factories/users.rb"
    end

    def user_tests
      copy_file "user_test.rb", "test/unit/user_test.rb"
    end
  end
end
