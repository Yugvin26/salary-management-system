# frozen_string_literal: true

require Rails.root.join("lib/seeding/configuration")

module Workforce
  class ProductionSeedError < StandardError; end

  class Seeder
    HR_EMAIL = Seeding::Configuration::HR_EMAIL
    DEMO_PASSWORD = Seeding::Configuration::DEMO_PASSWORD

    def self.call(profile: ENV.fetch("SEED_PROFILE", "default"))
      raise ProductionSeedError, "Refusing to run assessment seed profiles in production" if Rails.env.production?

      require Rails.root.join("lib/seeding/seed_runner")
      Seeding::SeedRunner.call(profile: profile)
    end
  end
end
