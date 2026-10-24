# frozen_string_literal: true

module Api
  class PasswordResetRequestsController < BaseController
    def index
      authorize PasswordResetRequest
      pagy, records = pagy(policy_scope(PasswordResetRequest).includes(:user).order(requested_at: :desc, id: :desc))
      render_data records.map { |record| request_payload(record) }, meta: pagination_meta(pagy)
    end

    def create
      record = PasswordResetRequest.find_or_initialize_by(user: current_user, status: :pending)
      record.company = current_user.company
      record.requested_at ||= Time.current
      authorize record
      record.save!
      render_data request_payload(record), status: record.previously_new_record? ? :created : :ok
    end

    def update
      record = policy_scope(PasswordResetRequest).find(params[:id])
      authorize record
      user = record.user
      user.password = params[:password]
      user.password_confirmation = params[:password_confirmation].presence || params[:password]
      PasswordResetRequest.transaction do
        user.save!
        record.update!(status: :completed, resolved_by: current_user, resolved_at: Time.current)
      end
      render_data request_payload(record)
    rescue ActiveRecord::RecordInvalid => e
      render_errors(e.record)
    end

    private

    def request_payload(record)
      {
        id: record.id,
        status: record.status,
        requested_at: record.requested_at,
        resolved_at: record.resolved_at,
        user: {
          id: record.user_id,
          name: record.user.name,
          email: record.user.email,
          employee_id: record.user.employee_id,
          role: record.user.role
        }
      }
    end
  end
end
