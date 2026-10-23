# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  it "requires name, city, and country" do
    location = build(:location, name: nil, city: nil, country: nil)
    expect(location).not_to be_valid
    expect(location.errors.attribute_names).to include(:name, :city, :country)
  end

  it "is valid with name, city, and country" do
    expect(build(:location)).to be_valid
  end

  it "cannot be deleted while employees are based there" do
    location = create(:location)
    create(:user, :employee, location: location)
    expect(location.destroy).to be(false)
    expect(described_class.exists?(location.id)).to be(true)
  end
end
