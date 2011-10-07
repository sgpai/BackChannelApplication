require 'test_helper'

class SearchFromHomePageTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "new user creation and new post" do
    #create an account
    visit(logins_path)
    click_on('create-account')
    fill_in('user_userName', :with => 'jyothi123')
    fill_in('user_password', :with => "jyothi")
    fill_in('user_password_confirmation',:with => "jyothi")
    fill_in('user_email', :with => 'jyothi@gmail.com')
     click_on('Create User')


    #see your user details
    click_on('your-account-icon')

    #finally sign-out.
     click_on('Sign Out')


  end

   test "search from main page" do
     #anyone can search without loggin in.
     visit("logins_path")
     fill_in('searchQuery', :with => "jyothi")
     click_on('search-icon')
   end


  test "admin functions" do
     #admin sign-in
     visit("logins#path")
     fill_in('userName',:with =>'admin123')
     fill_in('password',:with=>'admin123')
     click_on('Sign-In')

     #see user dashboard
     click_on('user-dashboard-icon')

     #create a new user
     click_on('new-user-icon')
     fill_in('user_userName', :with => 'jyothiR')
    fill_in('user_password', :with => "jyothiR")
    fill_in('user_password_confirmation',:with => "jyothiR")
    fill_in('user_email', :with => 'jyothir@gmail.com')
     click_on('Create User')

     #delete a user
      click_on('user-dashboard-icon')
      click_on('delete-icon-10')

    click_on('home-icon')

     #finally SignOut.
    click_on('Sign Out')
  end
end