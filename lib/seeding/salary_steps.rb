# frozen_string_literal: true

require_relative "salary_generator"

module Seeding
  module SalarySteps
    def seed_salaries(configuration:, locations:)
      currency_by_location = locations.to_h { |location, currency| [ location.id, currency ] }
      now = Time.current
      batch_size = configuration.fetch(:salary_batch_size)

      User.employee.in_batches(of: batch_size) do |batch|
        rows = batch.pluck(:id, :location_id).map do |employee_id, location_id|
          SalaryGenerator.call(
            employee_id: employee_id,
            location_id: location_id,
            currency_by_location: currency_by_location,
            now: now
          )
        end
        Salary.insert_all!(rows)
      end
    end
  end
end
