require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

   # Reject post with empty attributes.
  test  "test_invalid_with_empty_attributes"   do
    p = Post.new
    assert_false p.save
  end

  #sucessfully creating a post when logged in.
  test "successful_post_addition" do
    id = User.find_by_userName("jyothi").id
          p = Post.new(:user_id => id  ,
                       :postString => "sometext",
                       :parentPostID=> 120)
     puts p
      assert_true p.save
  end

   #  the post string ust be greater than zero.
  test "post_string_must_be_greater_than_zero" do
    id = User.find_by_userName("jyothi").id
          p = Post.new(:user_id => id  ,
                       :postString => "",
                       :parentPostID=> 120)
    puts p
      assert_false p.save
  end
end
