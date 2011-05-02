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
      flash[:success] = 'Signed in!'
    else
      user = User.create_from_omniauth_hash(auth)
      flash[:success] = 'Successfully created your account!'
    end

    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :success => 'Signed out!'
  end
        RUBY
      end
    end

    def add_routes
      route "resources :sessions, :only => [:create, :destroy]"
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

    def controller_tests
      insert_into_file "test/functional/sessions_controller_test.rb", :after => "class SessionsControllerTest < ActionController::TestCase\n" do
        <<-RUBY
  setup do
    @omniauth_hash = {
      "user_info" => {
        "name" => "John Doe"
      },
      "uid" => 1234,
      "provider" => "thirty_seven_signals"
    }

    request.env['omniauth.auth'] = @omniauth_hash
    @user = Factory.create(:user)
  end

  test "routes" do
    assert_routing '/signout', {
      :controller => 'sessions', :action => 'destroy' }

    assert_recognizes({
      :controller => 'sessions',
      :action => 'create',
      :provider => 'thirty_seven_signals' },
      { :path => 'auth/thirty_seven_signals/callback', :method => 'post' })
  end

  test "post to create with existing user" do
    User.expects(:find_by_provider_and_uid)
      .with('thirty_seven_signals', 1234)
      .returns(@user)

    post :create

    assert_response :redirect
    assert_equal 'Signed in!', flash[:success]
    assert_equal @user.id, session[:user_id]
  end

  test "post to create without existing user" do
    User.expects(:find_by_provider_and_uid)
      .returns(nil)

    User.expects(:create_from_omniauth_hash)
      .with(@omniauth_hash)
      .returns(@user)

    post :create

    assert_response :redirect
    assert_equal 'Successfully created your account!', flash[:success]
    assert_equal @user.id, session[:user_id]
  end

  test "delete to destroy" do
    session[:user_id] = 1
    delete :destroy

    assert_nil session[:user_id]
    assert_response :redirect
  end
        RUBY
      end
    end
  end
end
