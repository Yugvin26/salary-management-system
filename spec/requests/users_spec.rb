# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users", type: :request do
  let(:hr) { create(:user) }
  let(:department) { create(:department) }
  let(:location) { create(:location) }

  def employee_payload(**overrides)
    {
      user: {
        email: "new.hire@acme.local", password: "password", first_name: "New", last_name: "Hire",
        role: "employee", work_mode: "hybrid", employee_id: "E90001", job_title: "Analyst",
        hire_date: "2024-02-01", department_id: department.id, location_id: location.id
      }.merge(overrides)
    }
  end

  before { sign_in_as(hr) }

  it "lets HR register an employee who can then sign in" do
    post "/api/users", params: employee_payload, as: :json
    expect(response).to have_http_status(:created)

    delete "/api/session", as: :json
    post "/api/session", params: { email: "new.hire@acme.local", password: "password" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(json.dig("data", "role")).to eq("employee")
  end

  it "does not let HR assign the HR role" do
    post "/api/users", params: {
      user: { email: "boss@acme.local", password: "password", first_name: "Bo", last_name: "Ss", role: "human_resource" }
    }, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "lets a company admin create another HR user" do
    admin = create(:user, role: :company_admin)
    sign_in_as(admin)
    post "/api/users", params: {
      user: { email: "boss@acme.local", password: "password", first_name: "Bo", last_name: "Ss", role: "human_resource" }
    }, as: :json
    expect(response).to have_http_status(:created)
    expect(json.dig("data", "role")).to eq("human_resource")
  end

  it "rejects a duplicate email" do
    create(:user, :employee, email: "taken@acme.local")
    post "/api/users", params: employee_payload(email: "taken@acme.local", employee_id: "E90002"), as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "email")).to be_present
  end

  it "rejects a mismatched password confirmation" do
    post "/api/users", params: employee_payload(password_confirmation: "different"), as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "password_confirmation")).to be_present
  end

  it "rejects a malformed employee id" do
    post "/api/users", params: employee_payload(employee_id: "12"), as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "employee_id")).to be_present
  end

  it "updates an existing user" do
    employee = create(:user, :employee)
    patch "/api/users/#{employee.id}", params: { user: { job_title: "Lead" } }, as: :json
    expect(response).to have_http_status(:ok)
    expect(employee.reload.job_title).to eq("Lead")
  end

  it "responds 404 when updating an unknown user" do
    patch "/api/users/0", params: { user: { job_title: "Lead" } }, as: :json
    expect(response).to have_http_status(:not_found)
  end
end
