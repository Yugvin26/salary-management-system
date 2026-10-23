# frozen_string_literal: true

require "rails_helper"

RSpec.describe "salaries", type: :request do
  let(:hr) { create(:user) }
  let(:employee) { create(:user, :employee) }

  before { sign_in_as(hr) }

  it "records a line, rejects invalid amount and currency, and replaces the current base" do
    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 90_000, currency: "USD", salary_type: "base", effective_on: "2024-01-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:created)
    first_id = json.dig("data", "id")

    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 0, currency: "USD", salary_type: "base", effective_on: "2024-06-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)

    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 10, currency: "usd", salary_type: "base", effective_on: "2024-06-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "currency")).to be_present

    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 95_000, currency: "USD", salary_type: "base", effective_on: "2025-01-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:created)
    second_id = json.dig("data", "id")

    get "/api/employees/#{employee.id}/salaries", as: :json
    expect(json["data"].map { |row| row["id"] }).to eq([ second_id, first_id ])
    expect(json["data"].map { |row| row["current"] }).to eq([ true, false ])

    get "/api/salaries/#{second_id}/versions", as: :json
    expect(json["data"].map { |row| row["event"] }).to include("create")
    expect(json["data"].first.dig("actor", "id")).to eq(hr.id)

    get "/api/salaries/#{first_id}/versions", as: :json
    update = json["data"].find { |row| row["event"] == "update" }
    expect(update["changeset"]["current"]).to eq([ true, false ])
    expect(update.dig("actor", "id")).to eq(hr.id)
  end

  it "keeps a bonus in history without replacing the current base" do
    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 80_000, currency: "USD", salary_type: "base", effective_on: "2026-01-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:created)

    post "/api/employees/#{employee.id}/salaries", params: {
      salary: { amount: 2_000, currency: "USD", salary_type: "bonus", effective_on: "2026-10-01", current: true }
    }, as: :json
    expect(response).to have_http_status(:created)
    expect(json.dig("data", "current")).to be(false)
    expect(json.dig("data", "salary_type")).to eq("bonus")

    get "/api/employees/#{employee.id}/salaries", as: :json
    rows = json["data"]
    expect(rows.find { |row| row["salary_type"] == "base" }["current"]).to be(true)
    expect(json.dig("meta", "monthly_payout", "bonus")).to eq("2000.00")
    expect(json.dig("meta", "monthly_payout", "base_monthly")).to eq("6666.67")
  end

  it "lets HR add a salary for another HR user" do
    other_hr = create(:user)
    post "/api/employees/#{other_hr.id}/salaries", params: {
      salary: { amount: 120_000, currency: "USD", salary_type: "base", effective_on: "2026-10-24", current: true }
    }, as: :json
    expect(response).to have_http_status(:created)
    expect(json.dig("data", "amount")).to eq("120000.00")
  end

  it "does not let HR change their own salary" do
    post "/api/employees/#{hr.id}/salaries", params: {
      salary: { amount: 120_000, currency: "USD", salary_type: "base", effective_on: "2026-10-24", current: true }
    }, as: :json
    expect(response).to have_http_status(:forbidden)
    expect(json.dig("errors", "base")).to include("You cannot change your own salary")
  end
end
