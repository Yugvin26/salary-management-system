# frozen_string_literal: true

require "rails_helper"

RSpec.describe Department, type: :model do
  it "requires a unique name regardless of case" do
    create(:department, name: "Engineering")
    duplicate = build(:department, name: "engineering")
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:name]).to be_present
  end

  it "requires a name" do
    expect(build(:department, name: "")).not_to be_valid
  end

  it "cannot be deleted while employees belong to it" do
    department = create(:department)
    create(:user, :employee, department: department)
    expect(department.destroy).to be(false)
    expect(department.errors[:base]).to be_present
    expect(described_class.exists?(department.id)).to be(true)
  end

  it "can be deleted when empty" do
    department = create(:department)
    expect { department.destroy }.to change(described_class, :count).by(-1)
  end
end
