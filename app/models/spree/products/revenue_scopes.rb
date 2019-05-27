module Spree
  class Product < Spree::Base
    module RevenueScopes
     extend ActiveSupport::Concern
      included do
        def revenue_last_week
          variants_including_master.sum(&:revenue_last_week)
        end

        def revenue_last_30_days
          variants_including_master.sum(&:revenue_last_30_days)
        end

        def revenue_between_days(date_range, order_scope = Spree::Order.all)
          variants_including_master.sum { |variant| variant.revenue_between_days(date_range, order_scope) }
        end

        def revenue_change(younger_range, older_range)
          older_revenue = revenue_between_days(older_range)
          younger_revenue = revenue_between_days(younger_range)

          return 0 if older_revenue.zero?
          younger_revenue / older_revenue
        end
      end
    end
  end
end
