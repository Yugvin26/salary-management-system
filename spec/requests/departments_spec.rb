# frozen_string_literal: true

require "rails_helper"

RSpec.describe "departments", type: :request do
  let(:hr) { create(:user) }

  before { sign_in_as(hr) }

  it "lists departments alphabetically" do
    create(:department, name: "Sales")
    create(:department, name: "Engineering")
    get "/api/departments", as: :json
    expect(json["data"].map { |row| row["name"] }).to eq(%w[Engineering Sales])
    expect(json["data"].first.keys).to contain_exactly("id", "name")
  end

  it "shows, updates and deletes an unused department" do
    department = create(:department, name: "Legal")
    get "/api/departments/#{department.id}", as: :json
    expect(json.dig("data", "name")).to eq("Legal")

    patch "/api/departments/#{department.id}", params: { department: { name: "Compliance" } }, as: :json
    expect(json.dig("data", "name")).to eq("Compliance")

    delete "/api/departments/#{department.id}", as: :json
    expect(response).to have_http_status(:ok)
    expect(json["data"]).to eq("id" => department.id, "deleted" => true)
    expect(Department.exists?(department.id)).to be(false)
  end

  it "rejects a blank name on create and update" do
    post "/api/departments", params: { department: { name: "" } }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)

    department = create(:department)
    patch "/api/departments/#{department.id}", params: { department: { name: "" } }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "ignores unpermitted attributes" do
    post "/api/departments", params: { department: { name: "Ops", id: 999_999 } }, as: :json
    expect(response).to have_http_status(:created)
    expect(json.dig("data", "id")).not_to eq(999_999)
  end

  it "rejects a duplicate department name and blocks delete while employees are assigned" do
    post "/api/departments", params: { department: { name: "Engineering" } }, as: :json
    expect(response).to have_http_status(:created)
    post "/api/departments", params: { department: { name: "Engineering" } }, as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "name")).to be_present

    department = Department.find_by!(name: "Engineering")
    create(:user, :employee, department: department)
    delete "/api/departments/#{department.id}", as: :json
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json.dig("errors", "base").join).to include("Employees are still assigned")
    expect(Department.exists?(department.id)).to be(true)
  end
end
