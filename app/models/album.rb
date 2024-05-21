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
#  invitees          :text             default([]), is an Array
#
# Indexes
#
#  index_albums_on_user_id  (user_id)
#
class Album < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  has_many :uploads, dependent: :destroy
  has_many :album_users, dependent: :destroy

  def cover
    return '' if photos.empty?

    [photos.first&.image, photos.first&.angle]
  end

  def attach_cover
    album_result = {}.merge(attributes)
    album_result[:cover] = cover[0]
    album_result[:angle] = cover[1]
    album_result
  end

  def share(emails, is_newly_created_album)
    # TODO: remove users that are not in the invitees list from the album users
    emails.each do |email|
      UserNotifierMailer.send_album_invitation_email(self, email).deliver
      user = User.find_by(email:)
      next unless user

      album_users.create(user_id: user.id) unless !is_newly_created_album && shared_with?(user)
    end
  end

  def shared_with?(user)
    album_users.exists?(user_id: user.id)
  end

  def remove_invitees(removed_invitees)
    # hide reviews of the removed invitees
    # remove those reviews from album average rating
    removed_invitees.each do |email|
      user = User.find_by(email:)
      next unless user

      album_users.find_by(user_id: user.id).destroy
    end
  end
end
