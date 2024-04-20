# == Schema Information
#
# Table name: reviews
#
#  id         :bigint           not null, primary key
#  name       :string
#  value      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Review < ApplicationRecord
  has_many :photo_user_reviews
  has_many :photos, through: :photo_user_reviews
end
