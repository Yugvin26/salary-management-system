# frozen_string_literal: true

module Api
  class PasswordResetsController < ApplicationController
    def create
      case account_kind
      when :staff
        reset_staff_password
      when :employee
        request_employee_reset
      when :ambiguous
        render json: {
          errors: { base: [ "This email is used in more than one company. Contact your company admin." ] }
        }, status: :unprocessable_entity
      else
        render json: {
          errors: {
            base: [
              "Password reset is available for a company admin or HR account. " \
              "Employees can request a reset with their company email."
            ]
          }
        }, status: :unprocessable_entity
      end
    end

    private

    def account_kind
      return :unavailable if matches.empty?
      return :ambiguous if matches.many?

      user = matches.first
      return :staff if user.company_admin? || user.human_resource?
      return :employee if user.employee?

      :unavailable
    end

    def matches
      @matches ||= User.where.not(role: User.roles[:super_admin]).with_email(params[:email]).to_a
    end

    def reset_staff_password
      if params[:password].blank?
        render json: { data: { result: "staff" } }
        return
      end

      user = matches.first
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation].presence || params[:password]
      if user.save
        render json: { data: { result: "reset" } }
      else
        render json: { errors: user.errors.to_hash(true) }, status: :unprocessable_entity
      end
    end

    def request_employee_reset
      user = matches.first
      record = PasswordResetRequest.find_or_initialize_by(user: user, status: :pending)
      record.company = user.company
      record.requested_at ||= Time.current
      record.save!
      render json: { data: { result: "requested" } }
    end
  end
end
