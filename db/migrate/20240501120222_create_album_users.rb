class CreateAlbumUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :album_users do |t|
      t.references :album, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
