# == Schema Information
#
# Table name: album_users
#
#  id         :bigint           not null, primary key
#  album_id   :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_album_users_on_album_id  (album_id)
#  index_album_users_on_user_id   (user_id)
#
class AlbumUser < ApplicationRecord
  belongs_to :album
  belongs_to :user
end
