Rails.application.config.after_initialize do
  ActiveSupport::Notifications.subscribe("device.deleted") do |event|
    DeviceDeletedNotificationJob.perform_later(event.payload)
  end
end
