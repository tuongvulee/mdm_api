require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  controller(described_class) do
    def record_not_found
      raise ActiveRecord::RecordNotFound.new("Couldn't find User", "User")
    end

    def record_invalid
      User.new.validate!
    end

    def param_missing
      params.require(:user)
    end
  end

  before do
    routes.draw do
      get "record_not_found" => "api/v1/base#record_not_found"
      get "record_invalid" => "api/v1/base#record_invalid"
      get "param_missing" => "api/v1/base#param_missing"
    end
  end

  it "returns 404 with a not_found error" do
    get :record_not_found

    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body["error"]).to eq(
      "code" => "not_found",
      "message" => "User not found"
    )
  end

  it "returns 422 with field-level validation details" do
    get :record_invalid

    expect(response).to have_http_status(:unprocessable_content)
    error = response.parsed_body["error"]
    expect(error["code"]).to eq("validation_failed")
    expect(error["details"].keys).to include("name", "email")
  end

  it "returns 400 when a required param is missing" do
    get :param_missing

    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body["error"]["code"]).to eq("bad_request")
  end
end
