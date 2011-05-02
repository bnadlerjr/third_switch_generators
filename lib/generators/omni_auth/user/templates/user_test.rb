require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = Factory.build(:user)
  end

  # Presence validator tests
  %w[name provider uid].each do |field|
    test "requires #{field}" do
      @user.send("#{field}=".to_sym, nil)
      assert(!@user.valid?)
      assert_equal ["can't be blank"], @user.errors[field.to_sym]
    end
  end

  test "enforces a unique uid" do
    Factory(:user)
    assert(!@user.valid?)
    assert_equal ["has already been taken"], @user.errors[:uid]
  end

  test "create new instance from omniauth hash" do
    user = User.create_from_omniauth_hash({
      "user_info" => {
        "name" => "John Doe"
      },
      "uid" => 1234,
      "provider" => "thirty_seven_signals"
    })

    assert(user.valid?)
  end
end
