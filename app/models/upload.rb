# == Schema Information
#
# Table name: uploads
#
#  id         :bigint           not null, primary key
#  name       :string
#  file_type  :string
#  progress   :integer
#  batch      :integer
#  album_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_uploads_on_album_id  (album_id)
#
class Upload < ApplicationRecord
  belongs_to :album
end
