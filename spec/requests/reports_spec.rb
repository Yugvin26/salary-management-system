# frozen_string_literal: true

require "rails_helper"

RSpec.describe "pay reports", type: :request do
  let(:hr) { create(:user) }

  before { sign_in_as(hr) }

  it "splits dashboard totals by currency and skips archived, bonus, and prior base lines" do
    usd_employee = create(:user, :employee, job_title: "Software Engineer")
    eur_employee = create(:user, :employee, location: create(:location, country: "Germany", city: "Berlin", name: "Berlin HQ"))
    archived = create(:user, :employee, active: false)
    create(:salary, employee: usd_employee, amount: 100, currency: "USD", current: true)
    create(:salary, employee: usd_employee, amount: 80, currency: "USD", current: false, effective_on: Date.new(2020, 1, 1))
    create(:salary, employee: eur_employee, amount: 50, currency: "EUR", current: true)
    create(:salary, employee: usd_employee, amount: 5, currency: "USD", salary_type: :bonus, current: true,
                    effective_on: Date.new(2024, 6, 1))
    create(:salary, employee: archived, amount: 999, currency: "USD", current: true)

    get "/api/reports/dashboard", as: :json
    expect(json.dig("data", "active_headcount")).to eq(2)
    totals = json.dig("data", "base_pay_by_currency")
    expect(totals).to include(
      hash_including("currency" => "USD", "total" => "100.00", "formatted_total" => "$100.00", "headcount" => 1),
      hash_including("currency" => "EUR", "total" => "50.00", "headcount" => 1)
    )
    expect(response.body).not_to match(/grand_total|converted/i)
  end

  it "groups current base pay by department, job title, and country" do
    engineering = create(:department, name: "Engineering")
    sales = create(:department, name: "Sales")
    berlin = create(:location, country: "Germany", city: "Berlin", name: "Berlin")
    nyc = create(:location, country: "United States", city: "New York", name: "NYC")
    engineer = create(:user, :employee, department: engineering, location: nyc, job_title: "Software Engineer")
    other = create(:user, :employee, department: engineering, location: berlin, job_title: "Software Engineer")
    seller = create(:user, :employee, department: sales, location: nyc, job_title: "Account Executive")
    create(:salary, employee: engineer, amount: 100, currency: "USD")
    create(:salary, employee: other, amount: 40, currency: "EUR")
    create(:salary, employee: seller, amount: 300, currency: "USD")

    get "/api/reports/departments", as: :json
    expect(json["meta"]["page"]).to eq(1)
    engineering_usd = json["data"].find { |row| row["department"] == "Engineering" && row["currency"] == "USD" }
    expect(engineering_usd["total"]).to eq("100.00")
    expect(engineering_usd["average"]).to eq("100.00")

    get "/api/reports/job_titles", as: :json
    title = json["data"].find { |row| row["job_title"] == "Account Executive" && row["currency"] == "USD" }
    expect(title["average"]).to eq("300.00")

    get "/api/reports/countries", as: :json
    country = json["data"].find { |row| row["country"] == "United States" && row["currency"] == "USD" }
    expect(country["headcount"]).to eq(2)
    expect(country["total"]).to eq("400.00")
  end

  it "exports a CSV with the salary columns" do
    employee = create(:user, :employee, employee_id: "E55555", first_name: "Casey", last_name: "Ng")
    create(:salary, employee: employee, amount: 120, currency: "USD")
    get "/api/reports/export"
    expect(response.media_type).to eq("text/csv")
    expect(response.body).to include("Employee ID", "Name", "Department", "Country", "Current Base Amount", "Currency")
    expect(response.body).to include("E55555", "Casey Ng", "120.00", "USD")
  end

  it "exports grouped report data for the selected tab" do
    create(:salary, employee: create(:user, :employee, department: create(:department, name: "Engineering")), amount: 250, currency: "USD")
    get "/api/reports/export_grouped", params: { grouped_type: "departments" }
    expect(response.media_type).to eq("text/csv")
    expect(response.body).to include("Group,Currency,Headcount,Total,Average")
    expect(response.body).to include("Engineering,USD")
  end

  it "supports pagination for grouped report endpoints" do
    40.times do |index|
      department = create(:department, name: "Dept #{index}")
      employee = create(:user, :employee, department: department, location: create(:location))
      create(:salary, employee: employee, amount: 100 + index, currency: "USD")
    end

    get "/api/reports/departments", params: { per_page: 10, page: 1 }, as: :json
    first_page_first_group = json["data"].first["department"]
    expect(json["data"].size).to eq(10)
    expect(json["meta"]["total"]).to be >= 40

    get "/api/reports/departments", params: { per_page: 10, page: 2 }, as: :json
    expect(json["data"].size).to eq(10)
    expect(json["data"].first["department"]).not_to eq(first_page_first_group)
  end
end
