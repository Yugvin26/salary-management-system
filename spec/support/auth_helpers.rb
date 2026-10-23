# frozen_string_literal: true

module AuthHelpers
  def json
    JSON.parse(response.body)
  end

  def sign_in_as(user, password: "password")
    post "/api/session", params: { email: user.email, password: password }, as: :json
    expect(response).to have_http_status(:ok)
  end
end
