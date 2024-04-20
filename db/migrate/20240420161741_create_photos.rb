class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.string :name
      t.string :image
      t.numeric :angle
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
  end
end
