# frozen_string_literal: true

require 'open-uri'
require './lib/modules/file_input'

# Uploads controller
class UploadsController < ApplicationController
  include FileInput
  before_action :set_upload, only: %i[show update destroy]
  before_action :set_album, only: %i[create show_progress]
  # skip_before_action :verify_authenticity_token
  # skip_before_action :authenticate_user!

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
    @upload = Upload.new(upload_params)

    if @upload.save
      render json: @upload, status: :created, location: @upload
    else
      render json: @upload.errors, status: :unprocessable_entity
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
    results = []
    file_names = JSON.parse(params[:file_names])
    file_types = JSON.parse(params[:file_types])
    file_names.each_with_index do |file_name, i|

      file_names.each_with_index do |file_name, i|
        return render(json: { error: 'Invalid file type.' }, status: :unprocessable_entity) unless check_file_type_whitelist!(file_name, file_types[i])
      end

      upload = Upload.find_by(
        album_id: params[:album_id],
        name: file_name,
        batch: @album.last_upload_batch
      )

      if upload
        results.push({ name: upload.name, progress: upload.progress }) if upload
      else
        results.push({ name: file_name, progress: 0 })
      end
    end
    render json: results
  end

  private

  def set_album
    @album = Album.find(params[:album_id])
  end

  def set_upload
    @upload = Upload.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def upload_params
    params.require(:upload).permit(:name, :progress, :album_id, :file_names, :file_types, :batch)
  end
end
