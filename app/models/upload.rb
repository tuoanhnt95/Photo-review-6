# == Schema Information
#
# Table name: uploads
#
#  id         :bigint           not null, primary key
#  name       :string
#  file_type  :string
#  progress   :integer
#  batch      :integer
#  albums_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_uploads_on_albums_id  (albums_id)
#
class Upload < ApplicationRecord
  belongs_to :albums
end
