class User < ActiveRecord::Base
  has_many :posts

  validates :userName, :presence => true, :length => {:minimum => 6, :maximum => 15}
  validates :password, :presence => true, :length => {:minimum => 6, :maximum => 15}
  validates :email, :presence => true, :length => {:minimum => 6, :maximum => 20}
  validates :loginType, :presence => true

  validates_presence_of :userName
  validates_uniqueness_of :userName
  validates_confirmation_of :password
end
