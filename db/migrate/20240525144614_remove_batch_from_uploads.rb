class RemoveBatchFromUploads < ActiveRecord::Migration[7.0]
  def change
    remove_column :uploads, :batch, :integer
  end
end
