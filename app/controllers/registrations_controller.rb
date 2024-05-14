# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  private

  def respond_with(resource, _opts = {})
    register_success(resource) && return if resource.persisted?

    register_failed(resource)
  end

  def register_success(resource)
    UserNotifierMailer.send_signup_email(resource).deliver
    # TODO
    # check if the user email is shared in the invitees list of any album?
    # registration email should have the link with the album shared with the user
    render jsonapi: resource
  end

  def register_failed(resource)
    render jsonapi_errors: resource.errors, status: :bad_request
  end
end
