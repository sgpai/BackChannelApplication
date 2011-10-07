require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  setup do

    @user = users(:one)
  end

  #check get for index page.
  test "get_index" do
    get :index
    assert_response :success
  end

  #login using correct password.
  test "correct_password" do
    put :create ,{:userName => @user.userName , :password => @user.password }
    assert_redirected_to(@user)
  end

  #login using wrong password- redirect to login page.
  test "wrong_password" do
    put :create ,{:userName => @user.userName , :password => "wrong" }
    assert_redirected_to(:controller => "logins", :action => "index")
  end


  #login of an unknown user- redirect to login page.
  test "unknown_user_redirection"  do
     put :create ,{:userName => "no name" , :password => "wrong" }
    assert_redirected_to(:controller => "logins", :action => "index")
  end

  #check for title and heading in the index page.
  test "login_index_rendering"  do
    get :index

    assert_select 'title', "BackChannelApp"
    assert_select 'h1', "Backchannel Application"

  end
end
