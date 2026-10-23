# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    include Pundit::Authorization
    include Pagy::Backend

    before_action :authenticate_user!
    before_action :set_paper_trail_whodunnit

    after_action :verify_authorized
    after_action :verify_policy_scoped, if: -> { action_name == "index" }

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from Pagy::VariableError, with: :invalid_pagination

    private

    def set_paper_trail_whodunnit
      PaperTrail.request.whodunnit = current_user&.id&.to_s
    end

    def render_data(data, status: :ok, meta: nil)
      body = { data: data }
      body[:meta] = meta if meta
      render json: body, status: status
    end

    def render_error(message, status:, field: :base)
      render json: { errors: { field => [ message ] } }, status: status
    end

    def render_errors(record)
      render json: { errors: record.errors.to_hash(true) }, status: :unprocessable_entity
    end

    def user_not_authorized
      render_error("You are not authorized to perform this action", status: :forbidden)
    end

    def record_not_found
      render_error("Not found", status: :not_found)
    end

    def record_invalid(error)
      render_errors(error.record)
    end

    def record_not_unique
      render_error("already exists", status: :unprocessable_entity)
    end

    def parameter_missing(error)
      render_error("Missing parameter: #{error.param}", status: :bad_request)
    end

    def invalid_pagination
      render_error("Invalid pagination parameters", status: :bad_request)
    end

    def current_company_id
      current_user.company_id
    end

    def pagination_meta(pagy)
      { page: pagy.page, per_page: pagy.limit, total: pagy.count, total_pages: pagy.pages }
    end
  end
end
