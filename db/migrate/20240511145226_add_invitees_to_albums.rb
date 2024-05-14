class AddInviteesToAlbums < ActiveRecord::Migration[7.0]
  def change
    add_column :albums, :invitees, :text, array: true, default: []
  end
end
