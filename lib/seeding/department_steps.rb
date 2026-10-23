# frozen_string_literal: true

module Seeding
  module DepartmentSteps
    def seed_departments(company)
      Configuration::DEPARTMENT_NAMES.map do |name|
        Department.find_or_create_by!(name: name, company: company)
      end
    end
  end
end
