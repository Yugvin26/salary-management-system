# frozen_string_literal: true

# Local and demo seed. Refuses to run in production.
# SEED_PROFILE=small  (~100 employees)
# SEED_PROFILE=default (~10,000 employees)
# SEED_PROFILE=large (~200,000 employees)
require Rails.root.join("lib/seeding/seed_runner")
Seeding::SeedRunner.call(profile: ENV.fetch("SEED_PROFILE", "default"))
