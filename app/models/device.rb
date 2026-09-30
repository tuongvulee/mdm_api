class Device < ApplicationRecord
  belongs_to :user

  enum :platform, { ios: "ios", android: "android", windows: "windows" }, validate: true
  enum :status, { active: "active", inactive: "inactive" }, validate: true

  normalizes :serial_number, with: ->(serial) { serial.strip.upcase }

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true
end
