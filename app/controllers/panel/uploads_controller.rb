# frozen_string_literal: true

require 'open-uri'
require './lib/modules/file_input'

# Uploads controller
module Panel
  class UploadsController < ApplicationController
    include FileInput
    before_action :set_album, only: %i[find_upload_by_name]
    before_action :set_upload, only: %i[show update destroy]

    # GET /uploads
    def index
      @uploads = Upload.all

      render json: @uploads
    end

    # GET /uploads/1
    def show
      render json: @upload
    end

    # POST /uploads
    def create
      upload = Upload.new(upload_params)

      if upload.save
        render json: upload, status: :created, location: upload
      else
        render json: upload.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /uploads/1
    def update
      if @upload.update(upload_params)
        render json: @upload
      else
        render json: @upload.errors, status: :unprocessable_entity
      end
    end

    # DELETE /uploads/1
    def destroy
      @upload.destroy
    end

    def show_progress
      unless check_file_type_whitelist!(params[:file_name], params[:file_type])
        return render(json: { error: 'Invalid file type.' }, status: :unprocessable_entity)
      end

      render json: find_upload_by_name
    end

    private

    # For last upload batch, increment in frontend and send it to backend, not increment per upload
    def find_upload_by_name
      upload = Upload.find_by(
        album_id: params[:album_id],
        name: params[:file_name]
      )

      { name: params[:file_name], progress: upload ? upload.progress : 0 }
    end

    def set_album
      @album = Album.find(params[:album_id])
    end

    def set_upload
      @upload = Upload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def upload_params
      params.require(:upload).permit(:name, :progress, :album_id, :file_name, :file_type, :batch)
    end
  end
end
