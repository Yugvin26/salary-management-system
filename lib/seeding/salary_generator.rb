# frozen_string_literal: true

module Seeding
  class SalaryGenerator
    def self.call(employee_id:, location_id:, currency_by_location:, now:)
      amount = 60_000 + ((employee_id % 40) * 1_000)
      {
        employee_id: employee_id,
        amount_cents: amount * 100,
        currency: currency_by_location.fetch(location_id),
        salary_type: Salary.salary_types[:base],
        effective_on: Date.new(2024, 1, 1),
        current: true,
        created_at: now,
        updated_at: now
      }
    end
  end
end
