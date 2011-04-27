module OmniAuth
  class SessionGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def generate_controller
      generate 'controller', 'sessions'
    end

    def create_controller_actions
      insert_into_file 'app/controllers/sessions_controller.rb', :after => "class SessionsController < ApplicationController\n" do
        <<-RUBY
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth['provider'], auth['uid'])
    if user
      session[:user_id] = user.id
      flash[:success] = 'Signed in!'
    else
      flash[:error] = 'Unable to sign in!'
    end

    redirect_to root_url
  end

  def destroy
    session[@current_user] = nil
    redirect_to root_url, :success => 'Signed out!'
  end
        RUBY
      end
    end

    def add_routes
      route "match '/auth/:provider/callback' => 'sessions#create'"
      route "match '/signout' => 'sessions#destroy', :as => :signout"
    end

    def current_user_helper_method
      insert_into_file "app/controllers/application_controller.rb", :after => "protect_from_forgery\n" do
        <<-RUBY
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session['user_id']) if session['user_id']
  end
        RUBY
      end
    end
  end
end
