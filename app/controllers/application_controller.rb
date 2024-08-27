class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include Pagy::Backend
  include Devise::Controllers::Helpers

  after_action { pagy_headers_merge(@pagy) if @pagy }

  # before_action :authenticate_user!, only: %i[panel]

  def website
    render template: 'layouts/website'
  end

  def panel
    p 'env secret key 1'
    # RAILS.logger.info ENV.fetch('secret_key_base', nil)
    # RAILS.logger.info ENV.fetch('DEVISE_JWT_SECRET_KEY', nil)
    # RAILS.logger.info ENV.fetch('devise_jwt_secret_key', nil)

    # p ENV.fetch('secret_key_base', nil)
    p 'panel'
    p user_signed_in?
    # return redirect_to website_path unless user_signed_in?

    render template: 'layouts/panel'
  end
end
