# frozen_string_literal: true

require "rails_helper"

RSpec.describe "locations", type: :request do
  let(:hr) { create(:user) }

  before { sign_in_as(hr) }

  it "lists locations by country, city and name" do
    create(:location, country: "India", city: "Pune", name: "Pune")
    create(:location, country: "Germany", city: "Berlin", name: "Berlin")
    get "/api/locations", as: :json
    expect(json["data"].map { |row| row["country"] }).to eq(%w[Germany India])
    expect(json["data"].first.keys).to contain_exactly("id", "name", "city", "country")
  end

  it "creates, shows, updates and deletes a location" do
    post "/api/locations", params: { location: { name: "Berlin Office", city: "Berlin", country: "Germany" } }, as: :json
    expect(response).to have_http_status(:created)
    id = json.dig("data", "id")

    get "/api/locations/#{id}", as: :json
    expect(json.dig("data", "city")).to eq("Berlin")

    patch "/api/locations/#{id}", params: { location: { city: "Munich" } }, as: :json
    expect(json.dig("data", "city")).to eq("Munich")

    delete "/api/locations/#{id}", as: :json
    expect(response).to have_http_status(:ok)
    expect(Location.exists?(id)).to be(false)
  end

  it "rejects missing attributes" do
    post "/api/locations", params: { location: { name: "Nowhere" } }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json["errors"].keys).to include("city", "country")
  end

  it "blocks delete while employees are assigned" do
    location = create(:location)
    create(:user, :employee, location: location)
    delete "/api/locations/#{location.id}", as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "base").join).to include("Employees are still assigned")
    expect(Location.exists?(location.id)).to be(true)
  end
end
