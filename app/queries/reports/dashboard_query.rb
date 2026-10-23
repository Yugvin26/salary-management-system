# frozen_string_literal: true

module Reports
  class DashboardQuery
    def initialize(company_id: nil)
      @company_id = company_id
    end

    def call
      active_employees = scoped_employees.where(active: true)
      totals = current_base.group(:currency).sum(:amount_cents)
      headcounts = current_base.group(:currency).count("DISTINCT users.id")

      {
        active_headcount: active_employees.count,
        base_pay_by_currency: format_totals(totals, headcounts)
      }
    end

    private

    def scoped_employees
      scope = User.employee
      scope = scope.where(company_id: @company_id) if @company_id
      scope
    end

    def current_base
      filters = { active: true, role: User.roles[:employee] }
      filters[:company_id] = @company_id if @company_id
      Salary.current_base.joins(:employee).where(users: filters)
    end

    def format_totals(totals, headcounts)
      rows = totals.map do |currency, total|
        {
          currency: currency,
          headcount: headcounts[currency].to_i,
          **Salary.money_fields(total, currency, :total)
        }
      end
      rows.sort_by { |row| row[:currency] }
    end
  end
end
