# frozen_string_literal: true

require './lib/modules/file_input'

# Photos controller
module Panel
  class PhotosController < ApplicationController
    include FileInput
    before_action :set_photo, only: %i[show update destroy]
    before_action :set_album, only: %i[index create create_new_upload]

    # GET /albums/:album_id/photos
    def index
      @photos = Photo.where(album_id: params[:album_id])
      # return photo objects with review results
      result = []
      @photos.each do |photo|
        photo_object = {}.merge(photo.attributes)
        photo_object[:review_results] = get_review_result(photo)
        result.push(photo_object)
      end
      render json: result
    end

    # GET /photos/:id
    def show
      render json: @photo
    end

    # POST /albums/:album_id/photos
    def create
      @album.increment(:last_upload_batch)
      results = []

      photo_params[:files].each do |file|
        # whitelist file types
        unless check_file_type_whitelist!(file.original_filename, file.content_type)
          return render(json: { error: 'Invalid file type.' }, status: :unprocessable_entity)
        end

        upload = create_new_upload(file)

        processed_image = ImageProcessor.call(file, photo_params[:upload_option], upload.id)
        photo = Photo.make_new_photo(processed_image, photo_params[:album_id])
        if photo.save
          results.push(photo)
          upload.update(progress: 100)
        else
          render json: photo.errors, status: :unprocessable_entity
        end
      end

      if results.empty?
        render(json: { error: 'Error uploading images' }, status: :unprocessable_entity)
      else
        render(json: results, status: :created)
      end
    end

    # PATCH/PUT /photos/:id
    def update
      if @photo.update(photo_params)
        render json: @photo
      else
        render json: @photo.errors, status: :unprocessable_entity
      end
    end

    # DELETE /photos/:id
    def destroy
      public_id = @photo.image
      @photo.destroy
      folder = 'photo_review/'
      Cloudinary::Uploader.destroy(folder + public_id)
    end

    # DELETE /photos/delete_photos
    def destroy_multiple
      params[:photo_ids].each do |photo_id|
        photo = Photo.find(photo_id)
        public_id = photo.image
        photo.destroy
        folder = 'photo_review/'
        Cloudinary::Uploader.destroy(folder + public_id)
      end
    end

    private

    def create_new_upload(file)
      Upload.create({
                      name: file.original_filename,
                      file_type: file.content_type,
                      progress: 15,
                      batch: @album.last_upload_batch,
                      album_id: photo_params[:album_id]
                    })
    end

    def get_review_result(photo)
      user = current_user
      reviews = photo.photo_user_reviews
      review_by_user = reviews.find { |review| review.user_id == user.id }
      # Only show result after current user has reviewed
      return nil if reviews.empty? || review_by_user.nil?

      get_result_all(reviews)
    end

    def get_result_all(reviews)
      values = reviews.map { |review| Review.find(review.review_id).value }
      if values.all?(1) # all yes
        3
      elsif values.all?(&:zero?) # all no
        1
      else
        2
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = Album.find(params[:album_id])
    end

    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.permit(:image, :angle, :album_id, :upload_option, files: [], photo_ids: [])
    end
  end
end
