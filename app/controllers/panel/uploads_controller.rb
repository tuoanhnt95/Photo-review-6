# frozen_string_literal: true

require 'open-uri'
require './lib/modules/file_input'

# Uploads controller
module Panel
  class UploadsController < ApplicationController
    include FileInput
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
      uploads = Upload.where(
        album_id: params[:album_id],
        name: params[:file_name]
      )

      # TODO: move delete cancelled uploads to a background job
      delete_cancelled_uploads(uploads) if uploads.length > 1
      upload_in_progress = uploads.last if uploads.length.positive? && !uploads.last.is_cancelled

      render json: { name: params[:file_name], progress: upload_in_progress ? upload_in_progress.progress : 0 }
    end

    def cancel
      uploads_in_progress = Upload.select do |upload|
        upload.album_id = params[:album_id] && upload.progress < 80 && !upload.is_cancelled
      end
      return render(json: { message: 'No uploads to cancel.' }) if uploads_in_progress.empty?

      uploads_in_progress.each do |upload|
        upload.is_cancelled = true
        upload.save
      end

      render(json: { message: 'Cancelled upload.' })
    end

    private

    def delete_cancelled_uploads(uploads)
      uploads.each do |upload|
        upload.destroy if upload.is_cancelled
      end
    end

    def set_upload
      @upload = Upload.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def upload_params
      params.require(:upload).permit(:name, :progress, :album_id, :file_name, :file_type)
    end
  end
end
