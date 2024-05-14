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

    photos.first&.image
  end

  def attach_cover
    album_result = {}.merge(attributes)
    album_result[:cover] = cover
    p '----------------------'
    p 'attach_cover'
    p cover
    p album_result
    p '----------------------'
    album_result
  end

  def share(emails, is_new)
    p '----------------------'
    p 'start share'
    p emails
    # TODO: remove users that are not in the invitees list from the album users
    emails.each do |email|
      p '----------------------'
      p 'loop email'
      p email
      UserNotifierMailer.send_album_invitation_email(self, email).deliver
      user = User.find_by(email:)
      p 'user'
      p user
      next unless user
      p '----------------------'
      p 'user exists. Is Album new?'
      p is_new
      p 'Is the album shared with the user?'
      p shared_with?(user)
      p !is_new && shared_with?(user)
      album_users.create(user_id: user.id) unless !is_new && shared_with?(user)
    end
  end

  def shared_with?(user)
    album_users.exists?(user_id: user.id)
  end
end
