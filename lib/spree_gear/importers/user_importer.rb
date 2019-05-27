# frozen_string_literal: true

# Imports products from
module SpreeGear
  module Importers
    class UserImporter
      def self.import(email)
        user = Spree::User.find_by_email(email)
        user ||= Spree::User.from_woo get_remote_user(email)
        user
      end

      def self.get_remote_user(email)
        user = JSON.load(open("#{ENV['WC_SITE_ROOT']}/check-user.php?wp_api_key=#{ENV['WC_API_KEY']}&email=#{email}"))
        user
      end
    end
  end
end

require "open-uri"
