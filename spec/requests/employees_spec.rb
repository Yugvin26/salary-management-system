# frozen_string_literal: true

require "rails_helper"

RSpec.describe "employee directory", type: :request do
  let(:hr) { create(:user) }
  let(:engineering) { create(:department, name: "Engineering") }
  let(:sales) { create(:department, name: "Sales") }
  let(:germany) { create(:location, country: "Germany", city: "Berlin", name: "Berlin") }
  let(:india) { create(:location, country: "India", city: "Bengaluru", name: "Bengaluru") }

  before { sign_in_as(hr) }

  it "searches, filters, and paginates employees" do
    match = create(:user, :employee, employee_id: "E10001", first_name: "Rita", last_name: "Ora", department: engineering,
                                     location: germany)
    create(:user, :employee, department: sales, location: india)
    create(:user, :employee, department: engineering, location: germany, active: false)
    create_list(:user, 30, :employee, department: engineering, location: germany)

    get "/api/employees", params: { q: "E10001" }, as: :json
    expect(json["data"].map { |row| row["id"] }).to eq([ match.id ])

    get "/api/employees", params: { department_id: engineering.id, status: "active", per_page: 100 }, as: :json
    ids = json["data"].map { |row| row["id"] }
    expect(ids).to include(match.id)
    expect(ids).not_to include(User.employee.find_by!(department: sales).id)
    expect(json["data"]).to all(include("active" => true))
    expect(json.dig("meta", "total")).to be > 25

    get "/api/employees", params: { department_id: engineering.id, status: "active", per_page: 25 }, as: :json
    expect(json["data"].length).to eq(25)
    expect(json.dig("meta", "page")).to eq(1)

    get "/api/employees", params: { department_id: engineering.id, status: "active", page: 2, per_page: 25 }, as: :json
    expect(json["data"]).not_to be_empty
  end

  it "creates, updates, archives, and unarchives an employee on users" do
    post "/api/employees", params: {
      employee: {
        email: "directory@acme.local", password: "password", first_name: "Dee", last_name: "Reed",
        employee_id: "E22222", job_title: "Analyst", work_mode: "remote", hire_date: "2022-03-01",
        department_id: engineering.id, location_id: germany.id
      }
    }, as: :json
    expect(response).to have_http_status(:created)
    id = json.dig("data", "id")
    expect(User.find(id).role).to eq("employee")
    expect(User.find(id).active).to be(true)

    delete "/api/session", as: :json
    post "/api/session", params: { email: "directory@acme.local", password: "password" }, as: :json
    expect(response).to have_http_status(:ok)
    delete "/api/session", as: :json
    sign_in_as(hr)

    post "/api/employees", params: {
      employee: {
        email: "directory@acme.local", password: "password", first_name: "Dee", last_name: "Reed",
        employee_id: "E22223", job_title: "Analyst", work_mode: "remote", hire_date: "2022-03-01",
        department_id: engineering.id, location_id: germany.id
      }
    }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "email")).to be_present

    patch "/api/employees/#{id}", params: { employee: { job_title: "Senior Analyst" } }, as: :json
    expect(json.dig("data", "job_title")).to eq("Senior Analyst")

    post "/api/employees/#{id}/archive", as: :json
    expect(json.dig("data", "active")).to be(false)
    get "/api/employees", as: :json
    expect(json["data"].map { |row| row["id"] }).not_to include(id)
    get "/api/employees", params: { status: "archived" }, as: :json
    expect(json["data"].map { |row| row["id"] }).to include(id)

    post "/api/employees/#{id}/unarchive", as: :json
    expect(response).to have_http_status(:ok)
    expect(json.dig("data", "active")).to be(true)
    get "/api/employees", as: :json
    expect(json["data"].map { |row| row["id"] }).to include(id)
    expect(User.exists?(id)).to be(true)
  end
end
