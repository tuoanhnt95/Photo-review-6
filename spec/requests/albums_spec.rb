# == Schema Information
#
# Table name: albums
#
#  id          :bigint           not null, primary key
#  name        :string
#  expiry_date :date
#  user_id     :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  invitees    :text             default([]), is an Array
#
# Indexes
#
#  index_albums_on_user_id  (user_id)
#
require 'rails_helper'

RSpec.describe "Albums", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end
end
