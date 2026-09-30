require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:devices).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value("test@example.com").for(:email) }
    it { is_expected.to_not allow_value("invalid-email").for(:email) }
  end

  describe "normalization" do
    it "strips and downcases email before validation" do
      user = create(:user, email: "  Test@Example.COM  ")
      expect(user.email).to eq("test@example.com")
    end
  end
end
