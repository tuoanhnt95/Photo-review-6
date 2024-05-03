class Panel::PhotoUserReviewsController < ApplicationController
  before_action :set_photo_user_review, only: %i[show destroy]
  before_action :set_photo, only: %i[index show create update show_by_photo_and_user]
  wrap_parameters false

  # GET photos/:photo_id/photo_user_reviews
  def index
    @photo_user_reviews = PhotoUserReview.all

    render json: @photo_user_reviews
  end

  # GET /photo_user_reviews/1
  def show
    render json: @photo_user_review
  end

  # POST photos/:photo_id/photo_user_reviews
  def create
    photo_user_review = PhotoUserReview.new
    photo_user_review.photo_id = @photo.id
    photo_user_review.user_id = current_user.id
    photo_user_review.review_id = params[:review_id]

    if photo_user_review.save
      [photo_user_review, 1]
    else
      [photo_user_review, 0]
    end
  end

  # PATCH/PUT photos/:photo_id/photo_user_reviews
  def update
    # if the angle change, update the photo
    @photo.update(angle: params[:angle]) if @photo.angle != params[:angle]

    photo_user_review = find_review_by_photo_and_user

    # create a new review if it doesn't exist
    if photo_user_review.nil?
      if !params[:review_id].nil?
        create_result = create
        if create_result[1] == 1
          render json: create_result[0], status: :created
        else
          render json: create_result[0].errors, status: :unprocessable_entity
        end
        return
      else
        return
      end
    end

    # check if review has changed before update
    return if photo_user_review.review_id == params[:review_id].to_i

    if photo_user_review.update(review_id: params[:review_id])
      render json: photo_user_review
    else
      render json: photo_user_review.errors, status: :unprocessable_entity
    end
  end

  # GET photos/:photo_id/get_review
  def show_by_photo_and_user
    review = find_review_by_photo_and_user

    if review.nil? || review.review_id.nil?
      return
    end

    render json: Review.find(review.review_id).value
  end

  private

  def find_review_by_photo_and_user
    PhotoUserReview.find_by(photo_id: params[:photo_id], user_id: current_user.id)
  end

  def set_photo
    @photo = Photo.find(params[:photo_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_photo_user_review
    @photo_user_review = PhotoUserReview.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def photo_user_review_params
    params.permit(:photo_id, :photo_user_review_id, :review_id, :angle)
  end
end
