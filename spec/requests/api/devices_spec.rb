require "rails_helper"

RSpec.describe "Api::V1::Devices", type: :request do
  describe "GET /api/v1/devices" do
    let(:alice) { create(:user) }
    let!(:alice_ios) { create(:device, user: alice, platform: "ios", status: "active") }
    let!(:alice_android) { create(:device, user: alice, platform: "android", status: "inactive") }
    let!(:other_windows) { create(:device, platform: "windows", status: "active") }

    def ids
      response.parsed_body["data"].pluck("id")
    end

    it "returns all devices ordered by id" do
      get "/api/v1/devices"

      expect(response).to have_http_status(:ok)
      expect(ids).to eq([ alice_ios.id, alice_android.id, other_windows.id ])
    end

    it "filters by user_id" do
      get "/api/v1/devices", params: { user_id: alice.id }
      expect(ids).to eq([ alice_ios.id, alice_android.id ])
    end

    it "filters by status" do
      get "/api/v1/devices", params: { status: "inactive" }
      expect(ids).to eq([ alice_android.id ])
    end

    it "combines filters" do
      get "/api/v1/devices", params: { user_id: alice.id, platform: "ios" }
      expect(ids).to eq([ alice_ios.id ])
    end
  end

  describe "POST /api/v1/devices" do
    let(:user) { create(:user) }
    let(:valid_attributes) do
      { user_id: user.id, name: "iPhone 16", platform: "ios", serial_number: " abc123 " }
    end

    it "creates an active device and returns 201" do
      expect {
        post "/api/v1/devices", params: { device: valid_attributes }, as: :json
      }.to change(Device, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["data"]).to include(
        "user_id" => user.id,
        "platform" => "ios",
        "serial_number" => "ABC123",
        "status" => "active"
      )
    end

    it "returns 422 for an unknown platform" do
      post "/api/v1/devices",
           params: { device: valid_attributes.merge(platform: "blackberry") }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig("error", "details", "platform")).to be_present
    end

    it "returns 422 when the serial number is already taken" do
      create(:device, serial_number: "ABC123")

      post "/api/v1/devices", params: { device: valid_attributes }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig("error", "details", "serial_number"))
        .to include("has already been taken")
    end

    it "returns 422 when the user does not exist" do
      post "/api/v1/devices",
           params: { device: valid_attributes.merge(user_id: 0) }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig("error", "details", "user")).to be_present
    end
  end

    describe "DELETE /api/v1/devices/:id" do
    include ActiveJob::TestHelper

    let!(:device) { create(:device) }

    it "deletes the device, returns 204 and enqueues a notification" do
      expect {
        delete "/api/v1/devices/#{device.id}"
      }.to change(Device, :count).by(-1)
        .and have_enqueued_job(DeviceDeletedNotificationJob)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 when the device does not exist" do
      delete "/api/v1/devices/0"

      expect(response).to have_http_status(:not_found)
    end
  end
end
