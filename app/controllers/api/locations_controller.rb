# frozen_string_literal: true

module Api
  class LocationsController < ReferenceDataController
    private

    def model_class = Location
    def serializer = LocationSerializer
    def default_order = %i[country city name]
    def permitted_params = params.require(:location).permit(:name, :city, :country)
  end
end
