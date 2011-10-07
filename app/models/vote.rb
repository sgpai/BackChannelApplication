class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates :numberOfVotes, :presence => true
  validates :user, :presence => :true
  validates :post, :presence => :true
end