# frozen_string_literal: true

module Api
  class SalaryVersionsController < BaseController
    # The salary itself is authorized, so there is no scope to apply.
    skip_after_action :verify_policy_scoped

    def index
      salary = Salary.joins(:employee).where(users: { company_id: current_company_id }).find(params[:salary_id])
      authorize salary, :show?
      pagy, versions = pagy(salary.versions.order(:created_at, :id))
      render_data SalaryVersionSerializer.many(
        versions,
        currency: salary.currency,
        salary_type: salary.salary_type
      ), meta: pagination_meta(pagy)
    end
  end
end
