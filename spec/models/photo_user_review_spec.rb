# == Schema Information
#
# Table name: photo_user_reviews
#
#  id         :bigint           not null, primary key
#  photo_id   :bigint           not null
#  user_id    :bigint           not null
#  review_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_photo_user_reviews_on_photo_id   (photo_id)
#  index_photo_user_reviews_on_review_id  (review_id)
#  index_photo_user_reviews_on_user_id    (user_id)
#
require 'rails_helper'

RSpec.describe PhotoUserReview, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
