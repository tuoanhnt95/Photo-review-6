# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  private

  def respond_with(resource, _opts = {})
    register_success(resource) && return if resource.persisted?

    register_failed(resource)
  end

  def register_success(resource)
    p 'register_success'
    p resource
    p resource.email
    UserNotifierMailer.send_signup_email(resource).deliver
    render jsonapi: resource
  end

  def register_failed(resource)
    render jsonapi_errors: resource.errors, status: :bad_request
  end
end
