class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string :name
      t.date :expiry_date
      t.integer :last_upload_batch, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
