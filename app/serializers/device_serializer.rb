class DeviceSerializer < ApplicationSerializer
  def as_json(*)
    {
      id: record.id,
      user_id: record.user_id,
      name: record.name,
      platform: record.platform,
      serial_number: record.serial_number,
      status: record.status,
      created_at: record.created_at.iso8601,
      updated_at: record.updated_at.iso8601
    }
  end
end
