# frozen_string_literal: true

require "csv"

module Reports
  class CsvExport
    EMPLOYEE_HEADERS = [
      "Employee ID",
      "Name",
      "Department",
      "Country",
      "Job Title",
      "Location",
      "Current Base Amount",
      "Currency"
    ].freeze
    GROUPED_HEADERS = %w[Group Currency Headcount Total Average].freeze

    def initialize(grouped_type: nil, company_id: nil)
      @grouped_type = grouped_type
      @company_id = company_id
    end

    def to_csv
      CSV.generate do |csv|
        if @grouped_type
          csv << GROUPED_HEADERS
          grouped_rows.each { |row| csv << row }
        else
          csv << EMPLOYEE_HEADERS
          rows.each { |row| csv << row }
        end
      end
    end

    private

    def rows
      scope = User.employee.where(active: true)
      scope = scope.where(company_id: @company_id) if @company_id
      scope
        .left_joins(:department, :location)
        .joins(current_base_join)
        .order(:last_name, :first_name, :id)
        .pluck(
          "users.employee_id",
          Arel.sql("CONCAT(users.first_name, ' ', users.last_name)"),
          "departments.name",
          "locations.country",
          "users.job_title",
          "locations.name",
          "salaries.amount_cents",
          "salaries.currency"
        ).map { |*profile, cents, currency| [ *profile, cents && Salary.amount_string(cents, currency), currency ] }
    end

    def current_base_join
      <<~SQL.squish
        LEFT JOIN salaries ON salaries.employee_id = users.id
          AND salaries.current = TRUE
          AND salaries.salary_type = #{Salary.salary_types[:base]}
      SQL
    end

    def grouped_rows
      key = case @grouped_type
            when "departments" then :department
            when "job_titles" then :job_title
            when "countries" then :country
            else
              raise ArgumentError, "Unknown grouped export type: #{@grouped_type}"
            end

      Reports::GroupedPayQuery.new(key, company_id: @company_id).call.map do |row|
        [ row[key], row[:currency], row[:headcount], row[:total], row[:average] ]
      end
    end
  end
end
