class AddIsCancelledToUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :is_cancelled, :boolean, null: false, default: false
  end
end
