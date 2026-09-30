require 'rails_helper'

RSpec.describe Device, type: :model do
  subject { build(:device) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:serial_number) }
    it { is_expected.to validate_uniqueness_of(:serial_number).ignoring_case_sensitivity }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:platform)
        .with_values(ios: "ios", android: "android", windows: "windows")
        .backed_by_column_of_type(:string)
        .validating
    end

    it do
      is_expected.to define_enum_for(:status)
        .with_values(active: "active", inactive: "inactive")
        .backed_by_column_of_type(:string)
        .validating
    end

    it "returns a validation error for an unknown platform instead of raising an exception" do
      device = build(:device, platform: "blackberry")

      expect(device).to be_invalid
      expect(device.errors[:platform]).to include("is not included in the list")
    end
  end

  describe "defaults and normalization" do
    it "is active by default" do
      expect(Device.new.status).to eq("active")
    end

    it "strips and upcases serial_number before validation" do
      device = create(:device, serial_number: "  sn1234567890  ")
      expect(device.serial_number).to eq("SN1234567890")
    end
  end
end
