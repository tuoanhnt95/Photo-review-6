module Panel
  class AlbumsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_album, only: %i[show update destroy]

    # GET /albums or /albums.json
    def index
      @albums = Album.all
      results = []

      @albums.each do |album|
        album_cover = ''
        album_cover = album.photos.first.image unless album.photos.first.nil?
        result = album_result(album, album_cover)
        results.push(result)
      end

      render json: results
    end

    # GET /albums/1 or /albums/1.json
    def show
      render json: @album
    end

    # GET /albums/new
    # def new
    #   @album = Album.new
    # end

    # GET /albums/1/edit
    # def edit; end

    # POST /albums or /albums.json
    def create
      @album = Album.new(album_params)
      @album.user = current_user

      if @album.save
        render json: @album, status: :created
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /albums/1 or /albums/1.json
    def update
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
      # @album.destroy
      if @album.destroy
        render json: { message: 'Album was successfully destroyed.' }
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def album_result(album, album_cover)
      album_result = {}.merge(album.attributes)
      album_result[:cover] = album_cover
      album_result
    end

    def set_album
      @album = Album.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def album_params
      params.require(:album).permit(:name, :expiry_date, :last_update_batch)
    end
  end
end
