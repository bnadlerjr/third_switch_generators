module OmniAuth
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def add_omniauth_to_gemfile
      gem 'omniauth', '0.1.6'
      run 'bundle install'
    end

    def create_initializer
      initializer('omniauth.rb') do
        <<-RUBY
Rails.application.config.middleware.use OmniAuth::Builder do
  # TODO: Configure OmniAuth provider(s). For example:
  # provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  # provider :facebook, 'APP_ID', 'APP_SECRET'
end
        RUBY
      end
    end
  end
end
