# frozen_string_literal: true

module Seeding
  module AdminUserSteps
    def seed_admin_user(company)
      password = hr_password
      hr = User.find_or_initialize_by(email: Configuration::HR_EMAIL, company: company)
      hr.assign_attributes(
        password: password,
        password_confirmation: password,
        role: :human_resource,
        first_name: "Avery",
        last_name: "Chen",
        active: true,
        employee_id: nil,
        job_title: nil,
        hire_date: nil,
        department: nil,
        location: nil,
        work_mode: nil
      )
      hr.save!
      hr
    end

    private

    def hr_password
      ENV.fetch("HR_PASSWORD", Configuration::LOCAL_HR_PASSWORD)
    end
  end
end
