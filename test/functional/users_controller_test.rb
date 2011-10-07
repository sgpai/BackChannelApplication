require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index  ,{} , {userName: @user.userName , password: @user.password }
    assert_redirected_to users_notauthorized_path
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
       u = User.new(:userName => "newUser1",
                       :password => "password1",
                       :email=> "email.com",
                       :loginType => "student")
      post :create,{user: u.attributes}
    end

    assert_redirected_to user_path(assigns(:user))


    #delete user
    assert_difference('User.count', -1) do
      delete :destroy, {id: @user.id } , {userName: 'admin123', password: 'admin123'}
    end
  end

  test "should show user" do
    get :show, {id: @user.to_param}  , {userName: @user.userName , password: @user.password }
    assert_response :success
  end

  test "should get edit" do
    get :edit,{ id: @user.to_param} , {userName: @user.userName , password: @user.password }
    assert_response :success
  end

  test "should update user" do
    put :update,{ id: @user.to_param, user: @user.attributes }, {userName: @user.userName , password: @user.password }
    assert_redirected_to @user
  end
end
