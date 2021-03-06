class UserReview < ApplicationRecord
  has_many :users
  belongs_to :review

  validates_uniqueness_of :user_id, :scope => [:review_id]

end
