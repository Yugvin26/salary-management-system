# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    company { Company.find_or_create_by!(name: "ACME Test") }
    sequence(:email) { |n| "person#{n}@acme.local" }
    password { "password" }
    password_confirmation { "password" }
    first_name { "Ada" }
    last_name { "Lovelace" }
    role { :human_resource }
    active { true }

    trait :employee do
      role { :employee }
      sequence(:employee_id) { |n| format("E%05d", n) }
      job_title { "Software Engineer" }
      work_mode { "remote" }
      hire_date { Date.new(2020, 1, 15) }
      department { association(:department, company: company) }
      location { association(:location, company: company) }
    end
  end
end
