module Spree
  PaymentMethod.class_eval do
    def self.check
      where(type: "Spree::PaymentMethod::Check").first
    end
  end
end
