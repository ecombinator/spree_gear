module Spree
  StockLocation.class_eval do
    if Rails.application.config.weight_management
      alias_method :old_move, :move

      def self.new_default
        Spree::StockLocation.new \
        name: 'default',
        active: true,
        propagate_all_variants: false,
        backorderable_default: true

      end

      # TODO-AM method is to complecated to understand/test
      # bread down, test
      def move variant, quantity, originator = nil
        if !variant.is_master? && variant.product.has_multiple_weights?
          main_variant = variant.product.lightest_or_master_variant(options_hash: variant.options_hash)
          if !main_variant.is_master?
            quantity = variant.convert_units_to quantity, main_variant
            variant = main_variant
          end
          old_move variant, quantity.floor, originator
          Spree::StockMovement.transaction do
            main_count_on_hand = count_on_hand variant

            variant.siblings.where(options_hash: variant.options_hash).each do |sibling|
              goal = variant.convert_units_to main_count_on_hand, sibling
              delta = (goal - (count_on_hand(sibling) || 0)).floor
              old_move sibling, delta, originator
            end
          end
        else
          old_move variant, quantity, originator
        end
      end

    end
  end
end
