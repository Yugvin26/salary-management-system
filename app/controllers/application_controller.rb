# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_csrf_cookie

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_csrf

  private

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = {
      value: form_authenticity_token,
      secure: Rails.env.production?,
      same_site: :lax,
      httponly: false
    }
  end

  def invalid_csrf
    render json: { errors: { base: [ "Invalid CSRF token" ] } }, status: :unprocessable_entity
  end

  def authenticate_user!
    return if current_user

    render json: { errors: { base: [ "Sign in required" ] } }, status: :unauthorized
  end
end
