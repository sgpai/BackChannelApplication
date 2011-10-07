require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    @post = posts(:one)
    @user = users(:two)
    @post3 = posts(:two)

  end
   #redirect if not logged in
  test "get index with out logging in" do
    get :index
     assert_redirected_to(:controller => "logins", :action => "index")
   end

  test "get new redirected when not logged in" do
    get :new
    assert_redirected_to(:controller => "logins", :action => "index")
  end

  #actions after logging in
  test "should get new if logged in" do
    get :new , nil , {userName: @user.userName , password: @user.password }
    assert_response :success
  end

  #create a sucessful post after logging in
  test "should create post" do
    assert_difference('Post.count') do
      uid = User.find_by_userName("jyothi").id
      p=Post.new(:user_id => uid  , :postString => "sometext")
      post :create,  {post: p.attributes} ,{userName: @user.userName , password: @user.password }
      assert_equal 'Post was successfully created.' , flash[:notice]
    end

    assert_redirected_to post_path(assigns(:post))
  end

   # no post should be created if not signed in
   test "test post creation failed" do

      uid = User.find_by_userName("jyothi").id
      p=Post.new(:user_id => uid  , :postString => "sometext")
      post :create,  {post: p.attributes}
      assert_redirected_to(:controller => "logins", :action => "index")
  end


  #get the edit page when logged in
  test "should get edit" do
    get :edit,{id: @post.to_param }, {userName: @user.userName , password: @user.password }
    assert_response :success
  end


  #no need to login - search criteria user
  test "search with user" do
    put :search ,{:selectSearch => "searchUser" , :searchQuery => "jyothi"}
    assert_not_nil assigns(:posts)
  end

  #no need to login  - search criteria content.
   test "search with content" do
    put :search ,{:selectSearch => "searchContent", :searchQuery=>"some"}
    assert_not_nil assigns(:posts)
   end

    # reply to a post.
  test "create reply" do
    uid = User.find_by_userName("jyothi").id
    put :createreply ,{:user_id => uid, :postString =>'somereplyString', :parentPostID => 1} , {userName: @user.userName , password: @user.password}
    assert_response :success
  end

end
