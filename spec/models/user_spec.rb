# frozen_string_literal: true

require "rails_helper"
require "support/macro_actions"

RSpec.model "Users", type: :model do
  before do
    created_country = create(:country)
    Spree::Config[:default_country_id] = created_country.id
  end

  describe "creating a user in the signup page" do
    it "should properly work with the correct steps"do
      user = Spree::User.create email: "test@test.test"
      expect(user.referral_token).to_not be_nil
    end
  end
end
