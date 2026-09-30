FactoryBot.define do
  factory :device do
    user
    name { Faker::Device.model_name }
    platform { "ios" }
    sequence(:serial_number) { |n| "SN#{n.to_s.rjust(10, '0')}" }
    status { "active" }
  end
end
