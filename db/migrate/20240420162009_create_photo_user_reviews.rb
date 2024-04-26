class CreatePhotoUserReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :photo_user_reviews do |t|
      t.references :photo, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :review, foreign_key: true

      t.timestamps
    end
  end
end
