# frozen_string_literal: true

require './lib/modules/file_input'

module Panel
  class PhotosController < ApplicationController
    include FileInput
    before_action :set_album, only: %i[check_owner index create create_new_upload]
    # Guest can view photos, photo, and upload photos
    before_action :check_authorized_user, only: %i[index show create update]
    before_action :set_photo, only: %i[show update destroy]
    # Only the owner can delete photos
    before_action :check_owner, only: %i[destroy destroy_multiple]

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

    # GET /albums/:album_id/photos/:id
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

    # PATCH/PUT /albums/:album_id/photos/:id
    def update
      # guest can only update the angle
      [:name, :image, :album_id].each do |key|
        return panel_album_photo_path if !check_if_change(key)
      end

      if @photo.update(photo_params)
        render json: @photo
      else
        render json: @photo.errors, status: :unprocessable_entity
      end
    end

    # DELETE /albums/:album_id/photos/:id
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

    def check_if_change(key)
      # if there is no change or no param :key, then return false
      if ((photo_params[key] && @photo.key == photo_params[key]) || !photo_params[key])
        return false
      else
        return true
      end
    end

    def check_authorized_user
      album_user = AlbumUser.find_by(album_id: params[:album_id], user_id: current_user.id)

      redirect_to panel_path if album_user.nil? && return
    end

    def check_owner
      return unless @album.user != current_user

      render(json: { error: 'Unauthorized' }, status: :unauthorized) && return
    end

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
