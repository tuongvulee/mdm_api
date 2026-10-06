require "rails_helper"

RSpec.describe DeviceDeletedNotificationJob do
  it "logs the deletion" do
    allow(Rails.logger).to receive(:info)

    described_class.perform_now(
      { device_id: 42, user_id: 7, serial_number: "SN1", platform: "ios", deleted_at: Time.current }
    )

    expect(Rails.logger).to have_received(:info).with(/device_id=42/)
  end
end
