# frozen_string_literal: true

module Api
  module SiteAdmin
    class SessionsController < ApplicationController
      def create
        user = User.super_admin.with_email(params[:email]).first
        if user&.valid_password?(params[:password].to_s) && user.active_for_authentication?
          sign_in(user)
          render json: { data: UserSerializer.one(user) }
        else
          render json: { errors: { base: [ "Invalid email or password" ] } }, status: :unauthorized
        end
      end
    end
  end
end
