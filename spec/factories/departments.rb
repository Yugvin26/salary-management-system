# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    company { Company.find_or_create_by!(name: "ACME Test") }
    sequence(:name) { |n| "Department #{n}" }
  end
end
