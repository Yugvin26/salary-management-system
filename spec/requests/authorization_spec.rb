# frozen_string_literal: true

require "rails_helper"

RSpec.describe "authorization", type: :request do
  let(:employee) { create(:user, :employee) }
  let(:other) { create(:user, :employee) }
  let(:salary) { create(:salary, employee: employee) }
  let(:other_salary) { create(:salary, employee: other) }

  describe "visitors" do
    {
      get: [ "/api/employees", "/api/departments", "/api/locations", "/api/profile",
             "/api/reports/dashboard", "/api/reports/export" ],
      post: [ "/api/employees", "/api/departments", "/api/locations", "/api/users" ]
    }.each do |verb, paths|
      paths.each do |path|
        it "get a 401 on #{verb.to_s.upcase} #{path}" do
          public_send(verb, path, as: :json)
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  describe "employees" do
    before { sign_in_as(employee) }

    it "can read only their own profile and salaries" do
      salary
      get "/api/profile", as: :json
      expect(response).to have_http_status(:ok)
      expect(json.dig("data", "id")).to eq(employee.id)
      expect(json.dig("data", "salaries").map { |row| row["id"] }).to eq([ salary.id ])
    end

    it "cannot browse the directory or see another employee" do
      get "/api/employees", as: :json
      expect(response).to have_http_status(:forbidden)
      get "/api/employees/#{other.id}", as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "cannot manage employees" do
      post "/api/employees", params: { employee: { first_name: "A" } }, as: :json
      expect(response).to have_http_status(:forbidden)
      patch "/api/employees/#{employee.id}", params: { employee: { job_title: "CEO" } }, as: :json
      expect(response).to have_http_status(:forbidden)
      post "/api/employees/#{employee.id}/archive", as: :json
      expect(response).to have_http_status(:forbidden)
      expect(employee.reload.job_title).not_to eq("CEO")
      expect(employee).to be_active
    end

    it "cannot read reports or export data" do
      %w[dashboard departments job_titles countries export].each do |report|
        get "/api/reports/#{report}", as: :json
        expect(response).to have_http_status(:forbidden), "expected 403 for #{report}"
      end
      get "/api/reports/export_grouped", params: { grouped_type: "departments" }
      expect(response).to have_http_status(:forbidden)
    end

    it "cannot manage departments or locations" do
      get "/api/departments", as: :json
      expect(response).to have_http_status(:forbidden)
      post "/api/locations", params: { location: { name: "HQ", city: "X", country: "Y" } }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(Location.where(name: "HQ")).to be_empty
    end

    it "can list their own salaries but not create or read other people's" do
      salary
      get "/api/employees/#{employee.id}/salaries", as: :json
      expect(response).to have_http_status(:ok)
      expect(json["data"].map { |row| row["id"] }).to eq([ salary.id ])

      post "/api/employees/#{employee.id}/salaries",
           params: { salary: { amount: 1, currency: "USD", salary_type: "base", effective_on: "2024-01-01" } }, as: :json
      expect(response).to have_http_status(:forbidden)

      get "/api/employees/#{other.id}/salaries", as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "can read the version history of their own salary only" do
      get "/api/salaries/#{salary.id}/versions", as: :json
      expect(response).to have_http_status(:ok)
      get "/api/salaries/#{other_salary.id}/versions", as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "cannot create or promote users" do
      post "/api/users", params: {
        user: { email: "boss@acme.local", password: "password", first_name: "Bo", last_name: "Ss", role: "human_resource" }
      }, as: :json
      expect(response).to have_http_status(:forbidden)
      patch "/api/users/#{other.id}", params: { user: { role: "human_resource" } }, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(other.reload.role).to eq("employee")
    end
  end

  describe "HR" do
    before { sign_in_as(create(:user)) }

    it "gets 404 JSON for unknown records" do
      get "/api/employees/0", as: :json
      expect(response).to have_http_status(:not_found)
      expect(json.dig("errors", "base")).to include("Not found")
    end

    it "can open another HR user" do
      hr_user = create(:user)
      get "/api/employees/#{hr_user.id}", as: :json
      expect(response).to have_http_status(:ok)
      expect(json.dig("data", "id")).to eq(hr_user.id)
    end

    it "gets 400 JSON when the wrapped params are missing" do
      post "/api/departments", params: {}, as: :json
      expect(response).to have_http_status(:bad_request)
      expect(json.dig("errors", "base").join).to include("department")
    end
  end
end
