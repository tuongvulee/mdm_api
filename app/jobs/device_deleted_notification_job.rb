class DeviceDeletedNotificationJob < ApplicationJob
  queue_as :default

  def perform(payload)
    Rails.logger.info(
      "[DeviceDeleted] device_id=#{payload[:device_id]} " \
      "serial_number=#{payload[:serial_number]} user_id=#{payload[:user_id]}"
    )
  end
end
