# == Schema Information
#
# Table name: albums
#
#  id                :bigint           not null, primary key
#  name              :string
#  expiry_date       :date
#  last_upload_batch :integer          default(0)
#  user_id           :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_albums_on_user_id  (user_id)
#
class Album < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :uploads, dependent: :destroy
end
