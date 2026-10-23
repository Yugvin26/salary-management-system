# frozen_string_literal: true

require_relative "employee_generator"

module Seeding
  module EmployeeSteps
    def seed_employees(configuration:, departments:, locations:, company:)
      raise "Seed departments and locations before employees." if departments.empty? || locations.empty?

      count = configuration.fetch(:employee_count)
      clear_existing_employee_data
      encrypted_password = Devise::Encryptor.digest(User, Configuration::DEMO_PASSWORD)
      now = Time.current
      batch_size = configuration.fetch(:employee_batch_size)

      (0...count).each_slice(batch_size) do |indexes|
        rows = indexes.map do |index|
          EmployeeGenerator.call(
            company: company,
            departments: departments,
            locations: locations,
            index: index,
            encrypted_password: encrypted_password,
            now: now
          )
        end
        User.insert_all!(rows)
      end
    end

    private

    def clear_existing_employee_data
      employee_ids = User.employee.select(:id)
      salary_ids = Salary.where(employee_id: employee_ids).select(:id)
      PaperTrail::Version.where(item_type: "Salary", item_id: salary_ids).delete_all
      Salary.where(employee_id: employee_ids).delete_all
      User.employee.delete_all
    end
  end
end
