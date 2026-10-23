# frozen_string_literal: true

require "rails_helper"

RSpec.describe "pagination", type: :request do
  let(:hr) { create(:user) }

  before do
    sign_in_as(hr)
    create_list(:user, 7, :employee)
  end

  def fetch(**params)
    get "/api/employees", params: params, as: :json
  end

  it "defaults to 25 per page with a full meta block" do
    fetch
    expect(json["meta"]).to eq("page" => 1, "per_page" => 25, "total" => 7, "total_pages" => 1)
  end

  it "pages through results" do
    fetch(per_page: 3, page: 1)
    first_ids = json["data"].map { |row| row["id"] }
    expect(json["meta"]).to include("total" => 7, "total_pages" => 3, "per_page" => 3)

    fetch(per_page: 3, page: 3)
    expect(json["data"].size).to eq(1)
    expect(json["data"].map { |row| row["id"] } & first_ids).to be_empty
  end

  it "caps per_page at 100" do
    fetch(per_page: 1_000)
    expect(json.dig("meta", "per_page")).to eq(100)
  end

  it "returns an empty page past the end instead of failing" do
    fetch(page: 99)
    expect(response).to have_http_status(:ok)
    expect(json["data"]).to eq([])
    expect(json.dig("meta", "total")).to eq(7)
  end

  it "rejects invalid paging parameters with a 400" do
    fetch(page: 0)
    expect(response).to have_http_status(:bad_request)
    fetch(per_page: -5)
    expect(response).to have_http_status(:bad_request)
    expect(json.dig("errors", "base")).to include("Invalid pagination parameters")
  end

  it "paginates grouped reports the same way" do
    5.times { |i| create(:salary, employee: create(:user, :employee, department: create(:department, name: "D#{i}"))) }
    get "/api/reports/departments", params: { per_page: 2, page: 3 }, as: :json
    expect(json["data"].size).to eq(1)
    expect(json["meta"]).to include("page" => 3, "per_page" => 2, "total" => 5, "total_pages" => 3)
  end
end
