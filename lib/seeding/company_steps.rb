# frozen_string_literal: true

require_relative "configuration"

module Seeding
  module CompanySteps
    def seed_company
      company = Company.find_or_create_by!(name: "ACME")
      company.create_setting! unless company.setting
      company
    end

    def seed_super_admin
      user = User.find_or_initialize_by(email: "superadmin@acme.local")
      user.assign_attributes(
        company: nil,
        password: ENV.fetch("HR_PASSWORD", "password"),
        password_confirmation: ENV.fetch("HR_PASSWORD", "password"),
        first_name: "Super",
        last_name: "Admin",
        role: :super_admin,
        active: true
      )
      user.save!
      user
    end

    def seed_company_admin(company)
      password = ENV.fetch("HR_PASSWORD", Configuration::LOCAL_HR_PASSWORD)
      admin = User.find_or_initialize_by(email: "admin@acme.local", company: company)
      admin.assign_attributes(
        password: password,
        password_confirmation: password,
        first_name: "Company",
        last_name: "Admin",
        role: :company_admin,
        active: true,
        employee_id: nil,
        job_title: nil,
        hire_date: nil,
        department: nil,
        location: nil,
        work_mode: nil
      )
      admin.save!
      admin
    end
  end
end
