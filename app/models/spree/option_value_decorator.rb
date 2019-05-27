module Spree
  OptionValue.class_eval do
    after_save :update_variant_hash
    after_destroy :update_variant_hash

    def self.weights
      Rails.cache.fetch("weight_option_values", expires_in: 72.hours) do
        joins(:option_type).where("spree_option_types.name = ?", "Weight")
      end
    end

    def update_variant_hash
      return unless variants.any?
      variants.each { |g| g.update_options_hash }
    end
  end
end
