# frozen_string_literal: true

module Panel
  class AlbumsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_album, only: %i[check_owner show update destroy list_removed_invitees list_added_invitees]
    before_action :check_authorized_user, only: %i[show]
    before_action :check_owner, only: %i[update destroy]

    # GET /albums or /albums.json
    def index
      results = []
      albums = set_albums

      unless albums.empty?
        albums.each do |album|
          results.push(album.attach_cover)
        end
      end

      render json: results
    end

    # GET /albums/1 or /albums/1.json
    def show
      return redirect_to panel_path if @album.nil?

      respond_to do |format|
        format.html { render template: 'layouts/panel'}
        format.json { render json: @album.attach_cover }
      end
    end

    # POST /albums or /albums.json
    def create
      album = Album.new(album_params)
      album.user = current_user
      invitees = sanitize_invitees_email unless params[:invitees].nil?

      if album.save
        AlbumUser.create(user: current_user, album:)
        album.share(invitees, true) unless invitees.nil?
        render json: album, status: :created
      else
        render json: album.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /albums/1 or /albums/1.json
    def update
      # only the owner can update the album
      return redirect_to panel_path if @album.user != current_user

      # if there are newly removed invitees and the user is not the owner, then return
      removed_invitees = list_removed_invitees
      if @album.user != current_user && !removed_invitees.empty?
        render(json: { error: 'You cannot remove invitee.' }, status: :unauthorized) && return
      end

      # check if there are newly added invitees
      invitees = list_added_invitees

      if @album.update(album_params)
        if removed_invitees.empty?
          render json: @album
        else
          @album.remove_invitees(removed_invitees)
          render json: { album: @album, invitees_were_removed: true }
        end
        @album.share(invitees, false) unless invitees.empty?
      else
        render json: @album.errors, status: :unprocessable_entity
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

    def list_removed_invitees
      return [] if @album.invitees.empty?

      @album.invitees - params[:invitees]
    end

    def list_added_invitees
      return [] if params[:invitees].empty?

      added_invitees = params[:invitees] - @album.invitees
      sanitize_invitees_email(added_invitees) unless added_invitees.empty?
    end

    def sanitize_invitees_email(emails = [])
      result = []
      emails.each do |invitee|
        result.push(invitee) if invitee != '' && invitee.match(URI::MailTo::EMAIL_REGEXP)
      end
      result
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
      params.require(:album).permit(:name, :expiry_date, :last_update_batch, invitees: [])
    end
  end
end
