# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSerializer do
  let(:employee) { create(:user, :employee) }

  it "exposes the public employee fields and nests relations" do
    salary = create(:salary, employee: employee, amount: 1234.5)
    json = described_class.one(employee.reload)

    expect(json).to include(id: employee.id, email: employee.email, role: "employee", active: true)
    expect(json[:department]).to eq(id: employee.department_id, name: employee.department.name)
    expect(json[:location]).to include(id: employee.location_id)
    expect(json[:current_base_salary]).to include(id: salary.id, amount: "1234.50")
  end

  it "never leaks credentials" do
    json = described_class.one(employee)
    expect(json.keys.map(&:to_s)).not_to include("password", "encrypted_password")
  end

  it "uses nil for missing relations" do
    json = described_class.one(create(:user))
    expect(json).to include(department: nil, location: nil, current_base_salary: nil)
  end

  it "serializes collections and nil" do
    expect(described_class.many([ employee ]).size).to eq(1)
    expect(described_class.one(nil)).to be_nil
  end
end
