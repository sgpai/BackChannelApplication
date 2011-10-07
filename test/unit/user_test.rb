require 'test_helper'
    #fixtures :users
class UserTest < ActiveSupport::TestCase

  # check for presence of al attributes
  test  "test_invalid_with_empty_attributes"   do
    user = User.new
    assert_false user.save
  end

  # minimun password length is 6.
  test "test_min req_for_password" do
    user = User.new(:userName => "jyothiareddy",
                       :password => "yyy",
                       :email=> "email.com",
                       :loginType => "user")
    assert_false user.save
  end

   #minimum length for username is 6.
    test "test_min req_for_username" do
    user = User.new(:userName => "jyo",
                       :password => "yyyyyyyy",
                       :email=> "email.com",
                       :loginType => "user")
    assert_false user.save
    end


  # max length of userName is 15.
  test "max length of user Name" do
            user = User.new(:userName => "newUser123456789",
                       :password => "password1",
                       :email=> "email.com",
                       :loginType => "user")
    assert_false user.save
  end

  #Maximun length for password is 15.
  test "max length for password" do
       user = User.new(:userName => "newUser12",
                       :password => "password12345678",
                       :email=> "email.com",
                       :loginType => "user")
    assert_false user.save
  end

  #unique user name
  test "user_already_exists"  do
      user = User.new(:userName => "jyothi",
                       :password => "password1",
                       :email=> "email.com",
                       :loginType => "user")
      assert_false user.save
  end

  # successful addition with a unique userName
  test "successful_addition" do
          user = User.new(:userName => "newUser",
                       :password => "password1",
                       :email=> "email.com",
                       :loginType => "user")
      assert_true user.save
  end


end
