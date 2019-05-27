module Spree
  class Product < Spree::Base
    module Helpers
     extend ActiveSupport::Concern
      included do
        # If whitelisted in public products searching
        def self.whitelisted_search_scope?(used_scope)
          [
            :ascend_by_updated_at,
            :ascend_by_master_price,
            :descend_by_master_price,
            :descend_by_popularity,
            :descend_by_variant_pricing,
            :ascend_by_variant_pricing,
            :variant_prices_between,
            :ascend_by_main_category_name,
            :ascend_by_brand_name,
            :by_supply
          ].include?(used_scope)
        end

        def self.sold_to(user)
          if user
            if user.admin?
              includes(:variants_including_master)
            elsif user.has_spree_role?("wholesaler")
              where(spree_variants: { sold_to_wholesalers: true })
            end
          end
          where(spree_variants: { sold_to_consumers: true })
        end

        def available
          available_on.present? && discontinue_on.nil? ? true : false
        end

        def available=(value)
          if [false, "false"].include?(value)
            self.available_on = nil
            self.discontinue_on = nil
          else
            self.available_on = Time.now.beginning_of_day
            self.discontinue_on = nil
          end
        end

        def update_stock_status
          update_column :stocked_for_the_week, variants_including_master.all?(&:stocked_for_the_week?)
        end

        def liberate_slug!
          old_slug = slug
          update_attribute :slug, "#{slug}-liberated-#{Time.current.to_i}"
          FriendlyId::Slug.where(slug: old_slug).delete_all
        end

        def name
          read_attribute(:name).gsub("&shy;", "")
        end

        def active?
          !deleted_at && (!discontinue_on || discontinue_on > Time.current)
        end

        def self.available_no_distinct
          available_on ||= Time.current
          not_discontinued.joins(master: :prices).where("#{Product.quoted_table_name}.available_on <= ?", available_on)
        end

        def has_any_stock?
          can_supply? && total_on_hand.positive?
        end
      end
    end
  end
end
