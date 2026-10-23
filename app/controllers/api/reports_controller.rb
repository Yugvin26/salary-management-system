# frozen_string_literal: true

module Api
  class ReportsController < BaseController
    GROUPED_EXPORT_TYPES = %w[departments job_titles countries].freeze

    GROUPED_ACTIONS = {
      departments: :department,
      job_titles: :job_title,
      countries: :country
    }.freeze

    def dashboard
      authorize :report, :dashboard?
      render_data Reports::DashboardQuery.new(company_id: current_company_id).call
    end

    GROUPED_ACTIONS.each do |action, group|
      define_method(action) do
        authorize :report, :"#{action}?"
        render_grouped(group)
      end
    end

    def export
      authorize :report, :export?
      send_data Reports::CsvExport.new(company_id: current_company_id).to_csv, filename: "employee-payroll.csv", type: "text/csv"
    end

    def export_grouped
      authorize :report, :export?
      grouped_type = params.fetch(:grouped_type)
      unless GROUPED_EXPORT_TYPES.include?(grouped_type)
        return render_error("Unknown grouped export type", status: :bad_request,
                                                           field: :grouped_type)
      end

      send_data Reports::CsvExport.new(grouped_type: grouped_type, company_id: current_company_id).to_csv,
                filename: "#{grouped_type}-report.csv",
                type: "text/csv"
    end

    private

    def render_grouped(group_key)
      pagy, rows = pagy_array(Reports::GroupedPayQuery.new(group_key, company_id: current_company_id).call)
      render_data rows, meta: pagination_meta(pagy)
    end
  end
end
