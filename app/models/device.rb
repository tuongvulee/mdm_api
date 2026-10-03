class Device < ApplicationRecord
  belongs_to :user

  enum :platform, { ios: "ios", android: "android", windows: "windows" }, validate: true
  enum :status, { active: "active", inactive: "inactive" }, validate: true

  scope :for_user, ->(user_id) { where(user_id:) if user_id.present? }
  scope :with_status, ->(status) { where(status:) if status.present? }
  scope :on_platform, ->(platform) { where(platform:) if platform.present? }

  normalizes :serial_number, with: ->(serial) { serial.strip.upcase }

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true
end
