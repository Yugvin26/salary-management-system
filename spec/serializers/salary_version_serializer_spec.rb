# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalaryVersionSerializer do
  let(:hr) { create(:user) }
  let(:salary) { create(:salary, amount: 90_000, currency: "USD") }

  before { PaperTrail.request.whodunnit = hr.id.to_s }

  it "reports the event, amount, formatted amount and actor" do
    salary
    row = described_class.many(salary.versions, currency: "USD").first

    expect(row).to include(event: "create", amount: "90000.00", formatted_amount: "$90,000.00", salary_type: "base")
    expect(row[:actor]).to eq(id: hr.id, name: hr.name, email: hr.email)
  end

  it "has a nil actor when the author is unknown" do
    salary
    PaperTrail.request.whodunnit = nil
    salary.update!(current: false)
    row = described_class.many(salary.versions.order(:id), currency: "USD").last
    expect(row[:event]).to eq("update")
    expect(row[:actor]).to be_nil
  end

  it "loads all actors with a single query" do
    salary
    create(:salary, employee: salary.employee, amount: 95_000, currency: "USD")
    versions = salary.versions.to_a + Salary.where.not(id: salary.id).flat_map(&:versions)
    queries = []
    callback = ->(*, payload) { queries << payload[:sql] if payload[:sql].match?(/FROM "users"/) }
    ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
      described_class.many(versions, currency: "USD")
    end
    expect(queries.size).to eq(1)
  end
end
