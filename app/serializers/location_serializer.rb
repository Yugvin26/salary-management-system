# frozen_string_literal: true

class LocationSerializer < ApplicationSerializer
  def as_json
    { id: record.id, name: record.name, city: record.city, country: record.country }
  end
end
