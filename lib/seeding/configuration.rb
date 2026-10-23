# frozen_string_literal: true

module Seeding
  module Configuration
    HR_EMAIL = "hr@acme.local"
    DEMO_PASSWORD = "DemoPass123!"
    LOCAL_HR_PASSWORD = "password"

    VALUES = {
      employee_batch_size: 1_000,
      salary_batch_size: 1_000
    }.freeze

    PROFILE_COUNTS = {
      small: 100,
      default: 10_000,
      large: 200_000
    }.freeze

    DEPARTMENT_NAMES = %w[Engineering Product Sales People Finance Support].freeze

    LOCATION_DATA = [
      { name: "New York HQ", city: "New York", country: "United States", currency: "USD" },
      { name: "London Office", city: "London", country: "United Kingdom", currency: "GBP" },
      { name: "Berlin Office", city: "Berlin", country: "Germany", currency: "EUR" },
      { name: "Bengaluru Office", city: "Bengaluru", country: "India", currency: "INR" },
      { name: "Sao Paulo Office", city: "Sao Paulo", country: "Brazil", currency: "BRL" }
    ].freeze

    JOB_TITLES = [
      "Software Engineer", "Product Manager", "Account Executive",
      "HR Partner", "Financial Analyst", "Support Specialist"
    ].freeze

    WORK_MODES = %w[remote hybrid in_office].freeze

    def self.for_profile(profile)
      name = case profile
             when String then profile.to_sym
             when Symbol then profile
             else
               raise ArgumentError, "Seed profile must be a string or symbol."
             end

      employee_count = PROFILE_COUNTS.fetch(name) do
        raise ArgumentError, "Unknown seed profile #{profile.inspect}. Available profiles: #{PROFILE_COUNTS.keys.join(', ')}."
      end

      VALUES.merge(employee_count: employee_count)
    end
  end
end
