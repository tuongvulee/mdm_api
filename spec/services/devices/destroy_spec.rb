require "rails_helper"

RSpec.describe Devices::Destroy do
  let!(:device) { create(:device) }

  it "destroys the device" do
    expect { described_class.call(device) }.to change(Device, :count).by(-1)
  end

  it "publishes a device.deleted event with the device details" do
    payloads = []
    callback = ->(event) { payloads << event.payload }

    ActiveSupport::Notifications.subscribed(callback, "device.deleted") do
      described_class.call(device)
    end

    expect(payloads.size).to eq(1)
    expect(payloads.first).to include(
      device_id: device.id,
      user_id: device.user_id,
      serial_number: device.serial_number
    )
  end
end
