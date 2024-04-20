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
require 'rails_helper'

RSpec.describe Photo, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
