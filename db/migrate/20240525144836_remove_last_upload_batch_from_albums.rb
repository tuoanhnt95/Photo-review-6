class RemoveLastUploadBatchFromAlbums < ActiveRecord::Migration[7.0]
  def change
    remove_column :albums, :last_upload_batch, :integer
  end
end
