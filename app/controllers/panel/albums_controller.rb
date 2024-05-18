# frozen_string_literal: true

module Panel
  class AlbumsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_album,
                  only: %i[check_owner show update add_invitees destroy list_removed_invitees list_added_invitees]
    before_action :check_authorized_user, only: %i[show add_invitees]
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
      invitees = sanitize_invitees_email(params[:album][:invitees])

      if album.save
        AlbumUser.create(user: current_user, album:)
        album.share(invitees, true) unless invitees.empty?
        render json: album, status: :created
      else
        render json: album.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /albums/1 or /albums/1.json
    def update
      removed_invitees = list_removed_invitees

      # check if there are newly added invitees
      invitees = sanitize_invitees_email(params[:album][:invitees])
      added_invitees = list_added_invitees(invitees)

      if @album.update(create_update_album(invitees))
        @album.remove_invitees(removed_invitees) unless removed_invitees.empty?
        render json: @album
        @album.share(added_invitees, false) unless added_invitees.empty?
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end

    def add_invitees
      invitees = sanitize_invitees_email(params[:album][:invitees])
      added_invitees = list_added_invitees(invitees)

      if @album.update(invitees:)
        render json: @album
        @album.share(added_invitees, false)
      else
        render json: @album.errors, status: :unprocessable_entity
      end
    end

    # DELETE /albums/1 or /albums/1.json
    def destroy
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

      @album.invitees - params[:album][:invitees]
    end

    def list_added_invitees(sanitized_invitees = [])
      return [] if sanitized_invitees.empty?

      sanitized_invitees - @album.invitees
    end

    def sanitize_invitees_email(emails = [])
      return [] if emails.empty? || emails.nil?

      result = []
      emails.each do |invitee|
        result.push(invitee) if invitee != '' && invitee.match(URI::MailTo::EMAIL_REGEXP)
      end
      result
    end

    def create_update_album(invitees = [])
      result = album_params.except(:invitees)
      result[:invitees] = invitees
      result
    end

    def set_album
      @album = if params[:id].present?
                 Album.find(params[:id])
               else
                 Album.find(params[:album_id])
               end
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
