# frozen_string_literal: true

FactoryBot.define do
  factory :salary do
    association :employee, factory: %i[user employee]
    amount { 90_000 }
    currency { "USD" }
    salary_type { :base }
    effective_on { Date.new(2024, 1, 1) }
    current { true }
  end
end
