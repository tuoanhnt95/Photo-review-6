# frozen_string_literal: true

module Panel
  class AlbumsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_album, only: %i[check_owner show update destroy]
    before_action :check_authorized_user, only: %i[show]
    before_action :check_owner, only: %i[update destroy]

    # GET /albums or /albums.json
    def index
      results = []
      albums = set_albums

      unless albums.empty?
        albums.each do |album|
          result = album_result(album)
          results.push(result)
        end
      end

      render json: results
    end

    # GET /albums/1 or /albums/1.json
    def show
      return redirect_to panel_path if @album.nil?

      render json: album_result(@album)
    end

    # POST /albums or /albums.json
    def create
      album = Album.new(album_params)
      album.user = current_user

      if album.save
        AlbumUser.create(user: current_user, album:)
        render json: album, status: :created
      else
        render json: album.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /albums/1 or /albums/1.json
    def update
      # only the owner can update the album
      return redirect_to panel_path if @album.user != current_user

      if @album.update(album_params)
        render json: @album
        # redirect_to album_url(@album), notice: "Album was successfully updated."
      else
        render json: @album.errors, status: :unprocessable_entity
        # render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /albums/1 or /albums/1.json
    def destroy
      # only the owner can delete the album
      return redirect_to panel_path if @album.user != current_user

      if @album.destroy
        render json: { message: 'Album was successfully destroyed.' }
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end

    private

    def check_authorized_user
      album_user = AlbumUser.find_by(album_id: params[:id], user_id: current_user.id)

      redirect_to panel_path if album_user.nil? && return
    end

    def check_owner
      return unless @album.user != current_user

      render(json: { error: 'Unauthorized' }, status: :unauthorized) && return
    end

    def album_result(album)
      album_cover = ''
      album_cover = album.photos.first.image unless album.photos.first.nil?
      album_result = {}.merge(album.attributes)
      album_result[:cover] = album_cover
      album_result
    end

    def set_album
      @album = Album.find(params[:id])
    end

    def set_albums
      # all albums that are shared with the current user (owner included)
      @albums = Album
                .left_outer_joins(:album_users)
                .where(album_users: { user_id: current_user.id })
                .distinct
    end

    # Only allow a list of trusted parameters through.
    def album_params
      params.require(:album).permit(:name, :expiry_date, :last_update_batch)
    end
  end
end
