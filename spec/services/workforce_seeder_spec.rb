# frozen_string_literal: true

require "rails_helper"

RSpec.describe Workforce::Seeder do
  it "loads the small profile with departments, countries, salaries, and an HR login" do
    described_class.call(profile: "small")

    expect(User.employee.count).to eq(100)
    expect(Department.count).to be > 1
    expect(Location.distinct.count(:country)).to be > 1
    expect(Salary.where(current: true, salary_type: :base).count).to eq(100)
    expect(PaperTrail::Version.count).to eq(0)

    hr = User.find_by!(email: Workforce::Seeder::HR_EMAIL)
    expect(hr).to be_human_resource
    expect(hr.valid_password?("password")).to be(true)
    sample = User.find_by!(email: "employee0001@acme.local")
    expect(sample.valid_password?(Workforce::Seeder::DEMO_PASSWORD)).to be(true)
  end

  it "refuses assessment seed profiles in production" do
    allow(Rails.env).to receive(:production?).and_return(true)
    expect { described_class.call(profile: "default") }.to raise_error(Workforce::ProductionSeedError, /production/)
    expect(User.count).to eq(0)
  end
end
