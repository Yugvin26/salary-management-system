# frozen_string_literal: true

require_relative "configuration"
require_relative "company_steps"
require_relative "department_steps"
require_relative "location_steps"
require_relative "admin_user_steps"
require_relative "employee_steps"
require_relative "salary_steps"

module Seeding
  class ProductionSeedError < StandardError; end

  class SeedRunner
    extend CompanySteps
    extend DepartmentSteps
    extend LocationSteps
    extend AdminUserSteps
    extend EmployeeSteps
    extend SalarySteps

    def self.call(profile: :default, environment: Rails.env)
      raise ProductionSeedError, "Refusing to run assessment seed profiles in production" if environment.production?

      configuration = Configuration.for_profile(profile)
      PaperTrail.request(enabled: false) do
        ActiveRecord::Base.transaction do
          company = seed_company
          seed_super_admin
          departments = seed_departments(company)
          locations = seed_locations(company)
          seed_admin_user(company)
          seed_company_admin(company)
          seed_employees(configuration: configuration, departments: departments, locations: locations, company: company)
          seed_salaries(configuration: configuration, locations: locations)
        end
      end
      configuration.fetch(:employee_count)
    end
  end
end
