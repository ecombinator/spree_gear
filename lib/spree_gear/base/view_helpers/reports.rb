module SpreeGear
  module Base
    module ViewHelpers
      module Reports
        def order_start_date
          if params[:category].present?
            Spree::Order.by_product_category_name(params[:category]).first&.created_at&.strftime("%Y-%m-%d")
          else
            Spree::Order.first&.created_at.strftime("%Y-%m-%d")
          end
        end

        def taxon_items(taxons = nil)
          line_items ||= Spree::LineItem.joins(:order).includes(:product)
          line_items = line_items.in_taxons(taxons) if taxons
          line_items
        end

        def leaf_categories
          Spree::Taxon.leaf_categories
        end

        def leaf_category_ids
          Rails.cache.fetch "leaf_category_ids", expires_in: 5.minutes do
            leaf_categories.map(&:id)
          end
        end

        def not_taxon_items(taxon_ids = Spree::Taxon.leaf_categories.map(&:id))
          Spree::LineItem.not_in_taxons(taxon_ids).joins(:order).includes(:product)
        end

        def completed_total(line_items, completed_range, attribute = :pre_tax_amount)
          line_items.
            where(spree_orders: {completed_at: completed_range}).
            inject(0) { |total, li| total += li.send(attribute) }.to_i
        end

        def paid_total(line_items, paid_range, attribute = :pre_tax_amount)
          line_items.
            includes(order: :payments).
            where(spree_orders: {payment_state: ["paid", "credit_owed"]}).
            where(spree_payments: {state: "completed", completed_at: paid_range}).
            inject(0) { |total, li| total += li.send(attribute) }.to_i
        end

        def shipped_total(line_items, shipped_range, attribute = :pre_tax_amount)
          line_items.
            includes(order: :shipments).
            where(spree_orders: { shipment_state: "shipped" }).
            where(spree_shipments: { state: "shipped", shipped_at: shipped_range }).
            inject(0) { |total, li| total += li.send(attribute) }
        end

        def monthly_ranges
          ranges = [ { name: "Past 30 Days", range: (30.days.ago..Time.now)}]
          ranges += (1..3).map do |months|
            {
                name: months.months.ago.strftime("%B"),
                range: months.months.ago.beginning_of_month..months.months.ago.end_of_month
            }
          end
          ranges
        end

        def weekly_ranges
          (1..7).map do |weeks|
            week_start = weeks.weeks.ago.beginning_of_week
            week_end = weeks.weeks.ago.end_of_week
            {
                name: "#{week_start.strftime("%b %-d")} - #{week_end.strftime("%-d")}",
                range: week_start..week_end
            }
          end
        end

        def daily_ranges
          (1..7).map do |days|
            {
                name: days.days.ago.strftime("%A"),
                range: days.days.ago.beginning_of_day.. days.days.ago.end_of_day
            }
          end
        end
      end
    end
  end
end
