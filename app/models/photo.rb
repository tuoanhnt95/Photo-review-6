# == Schema Information
#
# Table name: photos
#
#  id         :bigint           not null, primary key
#  name       :string
#  image      :string
#  angle      :decimal(, )
#  album_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_photos_on_album_id  (album_id)
#
class Photo < ApplicationRecord
  belongs_to :album
  has_many :photo_user_reviews, dependent: :destroy
  has_many :reviews, through: :photo_user_reviews

  validates :album_id, presence: true
  validates :image, presence: true

  def self.make_new_photo(img, album_id)
    Photo.new({
                name: img[:img_name],
                image: img[:img_url],
                angle: 0,
                album_id: album_id
              })
  end
end
