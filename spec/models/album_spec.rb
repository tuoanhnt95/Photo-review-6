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
require 'rails_helper'

RSpec.describe Album, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
