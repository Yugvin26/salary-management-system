# frozen_string_literal: true

module Api
  class UsersController < BaseController
    def create
      authorize User, :create?
      user = User.new(registration_attributes.merge(company: current_user.company))
      authorize_hr_assignment(user)
      save_and_render(user, status: :created)
    end

    def update
      user = User.where(company_id: current_company_id).find(params[:id])
      authorize user, :update?
      user.assign_attributes(registration_attributes)
      authorize_hr_assignment(user)
      save_and_render(user)
    end

    private

    def authorize_hr_assignment(user)
      authorize user, :assign_hr_role? if user.human_resource?
    end

    def save_and_render(user, status: :ok)
      if user.save
        render_data UserSerializer.one(user), status: status
      else
        render_errors(user)
      end
    end

    def registration_attributes
      attrs = user_params.to_h.symbolize_keys
      attrs[:role] = requested_hr_role? ? "human_resource" : (attrs[:role].presence || "employee")
      attrs
    end

    def requested_hr_role?
      params.dig(:user, :role).to_s == "human_resource"
    end

    def user_params
      params.require(:user).permit(*policy(User).permitted_attributes)
    end
  end
end
