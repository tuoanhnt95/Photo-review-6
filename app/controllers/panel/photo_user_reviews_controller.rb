class PhotoUserReviewsController < ApplicationController
  before_action :set_photo_user_review, only: %i[show destroy]
  before_action :set_photo, only: %i[index show create]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

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
    @photo_user_review = PhotoUserReview.new(photo_user_review_params)

    if @photo_user_review.save
      render json: @photo_user_review, status: :created, location: @photo_user_review
    else
      render json: @photo_user_review.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT photos/:photo_id/photo_user_reviews
  def update
    # if the angle change, update the photo
    photo = Photo.find(params[:photo_id])
    photo.update(angle: params[:angle]) if photo.angle != params[:angle]

    # get the review_id from review value in params
    review_value = params[:review_value]
    review_id = nil
    review_id = Review.find_by(value: review_value).id unless review_value.nil?
    photo_user_review = find_review_by_photo_and_user

    # create a new review if it doesn't exist
    if photo_user_review.nil?
      user = User.first
      photo_user_review = PhotoUserReview.create(
        photo_id: params[:photo_id],
        user_id: user.id,
        review_id: review_id
      )
      render json: photo_user_review
      return
    end
    # check if review_id has changed before update
    return if photo_user_review.review_id == review_id

    if photo_user_review.update(review_id: review_id)
      render json: photo_user_review
    else
      render json: photo_user_review.errors, status: :unprocessable_entity
    end
  end

  # DELETE /photo_user_reviews/1
  def destroy
    @photo_user_review.destroy
  end

  # GET photos/:photo_id/get_review
  def show_by_photo_and_user
    review = find_review_by_photo_and_user

    if review.nil? || review.review_id.nil?
      render json: -1
      return
    end

    render json: Review.find(review.review_id).value
  end

  private

  def find_review_by_photo_and_user
    user = User.first
    PhotoUserReview.find_by(photo_id: params[:photo_id], user_id: user.id)
  end

  def photo_user_review_result(photo_user_review)
    photo_user_review_result = {}
    photo_user_review_result[:id] = photo_user_review.id
    photo_user_review_result[:review_name] = Review.find(photo_user_review.review_id).name
    photo_user_review_result[:review_value] = Review.find(photo_user_review.review_id).value
    photo_user_review_result
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
    params.permit(:photo_id, :photo_user_review_id, :review_value, :angle)
  end
end
