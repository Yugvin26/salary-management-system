# frozen_string_literal: true

module Api
  class SessionsController < ApplicationController
    before_action :authenticate_user!, only: %i[show destroy]

    def show
      render json: { data: UserSerializer.one(current_user) }
    end

    def create
      user = company_user_for(params[:email], params[:password])
      if user&.active_for_authentication?
        sign_in(user)
        render json: { data: UserSerializer.one(user) }
      else
        render json: { errors: { base: [ "Invalid email or password" ] } }, status: :unauthorized
      end
    end

    def destroy
      sign_out(current_user)
      render json: { data: { signed_out: true } }
    end

    private

    def company_user_for(email, password)
      matches = User.where.not(role: User.roles[:super_admin]).with_email(email)
      authenticated = matches.select { |user| user.valid_password?(password.to_s) }
      authenticated.first if authenticated.one?
    end
  end
end
