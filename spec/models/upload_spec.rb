# == Schema Information
#
# Table name: uploads
#
#  id           :bigint           not null, primary key
#  name         :string
#  file_type    :string
#  progress     :integer
#  album_id     :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_cancelled :boolean          default(FALSE), not null
#
# Indexes
#
#  index_uploads_on_album_id  (album_id)
#
require 'rails_helper'

RSpec.describe Upload, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
