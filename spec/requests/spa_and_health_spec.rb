# frozen_string_literal: true

require "rails_helper"

RSpec.describe "application shell", type: :request do
  it "serves the health endpoint" do
    get "/up"
    expect(response).to have_http_status(:ok)
  end

  it "serves the SPA shell at the root" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('id="root"')
  end

  it "serves the SPA shell for client-side routes opened in a browser" do
    get "/employees/42", headers: { "Accept" => "text/html" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('id="root"')
  end

  it "does not swallow unknown API routes into the SPA" do
    get "/api/nope", headers: { "Accept" => "application/json" }
    expect(response).to have_http_status(:not_found)
  end

  it "does not serve the SPA for non-HTML requests such as missing files" do
    get "/missing.png", headers: { "Accept" => "image/png" }
    expect(response).to have_http_status(:not_found)
  end
end
