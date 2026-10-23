# frozen_string_literal: true

require_relative "../seeding/configuration"

namespace :db do
  namespace :seed do
    Seeding::Configuration::PROFILE_COUNTS.each_key do |profile|
      desc "Seed employee data using the #{profile} profile"
      task profile => :environment do
        require Rails.root.join("lib/seeding/seed_runner")
        Seeding::SeedRunner.call(profile: profile)
      end
    end
  end
end
