class Post < ActiveRecord::Base
  belongs_to :user

  #validates :parentPostID, :presence => true
  validates :postString, :presence => :true, :length => {:minimum => 0, :maximum => 200}
  validates :user, :presence => :true
  #validates :totalVotes
  #validates :weight, :presence => :true
end