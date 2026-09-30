class User < ApplicationRecord
  has_many :devices, dependent: :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
end
