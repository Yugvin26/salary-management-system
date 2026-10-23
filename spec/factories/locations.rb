# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    company { Company.find_or_create_by!(name: "ACME Test") }
    sequence(:name) { |n| "Office #{n}" }
    city { "Berlin" }
    country { "Germany" }
  end
end
