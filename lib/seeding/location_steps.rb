# frozen_string_literal: true

module Seeding
  module LocationSteps
    def seed_locations(company)
      Configuration::LOCATION_DATA.map do |attributes|
        location = Location.find_or_create_by!(name: attributes[:name], company: company) do |record|
          record.city = attributes[:city]
          record.country = attributes[:country]
        end
        [ location, attributes[:currency] ]
      end
    end
  end
end
