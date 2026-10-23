# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employees::DirectoryQuery do
  let(:department) { create(:department) }
  let!(:rita) do
    create(:user, :employee, first_name: "Rita", last_name: "Ora", email: "rita@acme.local", employee_id: "E10001", department: department)
  end
  let!(:percent) { create(:user, :employee, first_name: "100%", last_name: "Sure", email: "pct@acme.local") }
  let!(:underscore) { create(:user, :employee, first_name: "A_B", last_name: "Under", email: "us@acme.local") }
  let!(:archived) { create(:user, :employee, first_name: "Old", last_name: "Timer", active: false) }

  def search(params = {})
    described_class.new(User.all, params).relation.to_a
  end

  it "defaults to active employees" do
    expect(search).to include(rita) & include(percent)
    expect(search).not_to include(archived)
  end

  it "filters by status" do
    expect(search(status: "archived")).to eq([ archived ])
    expect(search(status: "all")).to include(archived, rita)
  end

  it "matches names, email and employee id case-insensitively" do
    expect(search(q: "rita")).to eq([ rita ])
    expect(search(q: "ORA")).to eq([ rita ])
    expect(search(q: "rita ora")).to eq([ rita ])
    expect(search(q: "acme.local")).to include(rita)
    expect(search(q: "E10001")).to eq([ rita ])
  end

  it "treats % and _ typed by the user as literal characters" do
    expect(search(q: "%")).to eq([ percent ])
    expect(search(q: "_")).to eq([ underscore ])
    expect(search(q: "A_B")).to eq([ underscore ])
    expect(search(q: "R_ta")).to be_empty
  end

  it "treats a backslash literally and does not break the query" do
    expect(search(q: "\\")).to be_empty
  end

  it "does not allow SQL injection through the search term" do
    expect(search(q: "'; DROP TABLE users; --")).to be_empty
    expect(User.count).to be > 0
  end

  it "ignores a blank search and caps very long terms" do
    expect(search(q: "   ")).to include(rita)
    expect { search(q: "a" * 10_000) }.not_to raise_error
  end

  it "filters by department and country" do
    berlin = create(:location, country: "Germany")
    in_berlin = create(:user, :employee, location: berlin)
    expect(search(department_id: department.id)).to eq([ rita ])
    expect(search(country: "Germany")).to include(in_berlin)
    expect(search(country: "Atlantis")).to be_empty
  end

  it "orders by last name, first name" do
    names = search.map(&:last_name)
    expect(names).to eq(names.sort)
  end
end
