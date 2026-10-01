require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "GET /api/v1/users" do
    it "returns all users ordered by id" do
      users = create_list(:user, 2)

      get "/api/v1/users"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].pluck("id")).to eq(users.map(&:id))
    end
  end

  describe "POST /api/v1/users" do
    let(:valid_params) { { user: { name: "Alice", email: "Alice@Example.com" } } }

    it "creates a user and returns 201" do
      expect {
        post "/api/v1/users", params: valid_params, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["data"]).to include(
        "name" => "Alice",
        "email" => "alice@example.com"
      )
    end

    it "returns 422 when the email is already taken" do
      create(:user, email: "alice@example.com")

      post "/api/v1/users", params: valid_params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig("error", "details", "email"))
        .to include("has already been taken")
    end

    it "returns 400 when user params are malformed" do
      post "/api/v1/users", params: { user: "oops" }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body.dig("error", "code")).to eq("bad_request")
    end
  end
end
