class CreateUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :file_type
      t.integer :progress
      t.integer :batch
      t.references :albums, null: false, foreign_key: true

      t.timestamps
    end
  end
end
