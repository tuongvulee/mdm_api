module Devices
  class Destroy
    EVENT = "device.deleted"

    def self.call(device)
      new(device).call
    end

    def initialize(device)
      @device = device
    end

    def call
      payload = build_payload
      device.destroy!

      ActiveRecord.after_all_transactions_commit do
        ActiveSupport::Notifications.instrument(EVENT, payload)
      end

      device
    end

    private

    attr_reader :device

    def build_payload
      {
        device_id: device.id,
        user_id: device.user_id,
        serial_number: device.serial_number,
        platform: device.platform,
        deleted_at: Time.current
      }
    end
  end
end
