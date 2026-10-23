# frozen_string_literal: true

require_relative "configuration"

module Seeding
  class EmployeeGenerator
    def self.call(company:, departments:, locations:, index:, encrypted_password:, now:) # rubocop:disable Metrics/ParameterLists
      require "faker"
      location, _currency = locations[index % locations.length]
      department = departments[index % departments.length]

      {
        company_id: company.id,
        email: format("employee%04d@acme.local", index + 1),
        encrypted_password: encrypted_password,
        role: User.roles[:employee],
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        employee_id: format("E%05d", index + 1),
        job_title: Faker::Job.title.presence || Configuration::JOB_TITLES[index % Configuration::JOB_TITLES.length],
        work_mode: Configuration::WORK_MODES[index % Configuration::WORK_MODES.length],
        hire_date: Date.new(2018, 1, 1) + (index % 1800),
        department_id: department.id,
        location_id: location.id,
        active: true,
        created_at: now,
        updated_at: now
      }
    end
  end
end
