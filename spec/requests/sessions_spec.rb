# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sessions", type: :request do
  let(:hr) { create(:user, email: "hr@acme.local") }
  let(:employee) { create(:user, :employee, email: "employee@acme.local") }

  it "starts an HR session and an employee session" do
    sign_in_as(hr)
    expect(json.dig("data", "role")).to eq("human_resource")

    delete "/api/session", as: :json
    sign_in_as(employee)
    expect(json.dig("data", "role")).to eq("employee")
  end

  it "returns the signed-in user" do
    sign_in_as(employee)
    get "/api/session", as: :json
    expect(response).to have_http_status(:ok)
    expect(json.dig("data", "id")).to eq(employee.id)
    expect(json.dig("data", "department", "id")).to eq(employee.department_id)
  end

  it "treats the email as case-insensitive and ignores surrounding whitespace" do
    post "/api/session", params: { email: "  #{hr.email.upcase} ", password: "password" }, as: :json
    expect(response).to have_http_status(:ok)
  end

  it "rejects unknown and wrong passwords with the same generic error" do
    create(:user, email: "known@acme.local")
    post "/api/session", params: { email: "missing@acme.local", password: "password" }, as: :json
    unknown = response.body
    expect(response).to have_http_status(:unauthorized)

    post "/api/session", params: { email: "known@acme.local", password: "wrong-password" }, as: :json
    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to eq(unknown)
    expect(json.dig("errors", "base")).to include("Invalid email or password")

    get "/api/session", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "ends the session on sign-out" do
    sign_in_as(hr)
    delete "/api/session", as: :json
    expect(response).to have_http_status(:ok)
    get "/api/employees", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "requires a session to sign out" do
    delete "/api/session", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects a mutating request without a CSRF token when protection is on" do
    ActionController::Base.allow_forgery_protection = true
    post "/api/session", params: { email: hr.email, password: "password" }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "base")).to include("Invalid CSRF token")
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  it "does not authenticate an archived employee" do
    archived = create(:user, :employee, active: false, email: "old@acme.local")
    post "/api/session", params: { email: archived.email, password: "password" }, as: :json
    expect(response).to have_http_status(:unauthorized)
    get "/api/profile", as: :json
    expect(response).to have_http_status(:unauthorized)
  end
end
