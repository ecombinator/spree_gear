module Spree
  class Product < Spree::Base
    module PriceRanges
      extend ActiveSupport::Concern
      included do

        def latest_price_range_for(variants, price_method = :price)
          variants = variants.reject{ |v| v.nil? || v.try(price_method).nil? }
          lowest_to_highest = variants.sort_by(&price_method)

          return [0,0] if lowest_to_highest.empty?
          lowest_price = lowest_to_highest.first.send(price_method)
          highest_price = lowest_to_highest.last.send(price_method)
          [lowest_price.to_f, highest_price.to_f]
        end

        def latest_price_ranges
          ranges = []
          relevant_variants = has_variants? ? variants : variants_including_master.where(is_master: true)
          ranges << latest_price_range_for(relevant_variants.sold_to_consumers, :price)
          relevant_variants = has_variants? ? variants : variants_including_master.where(is_master: true)
          ranges << latest_price_range_for(relevant_variants.sold_to_wholesalers, :wholesale_price_or_nil)
          ranges
        end

        def update_price_ranges
          ranges = latest_price_ranges
          update_columns price_range: ranges[0],
                         wholesale_price_range: ranges[1]
          update_range_extents(ranges[0], "consumer")
          update_range_extents(ranges[1], "wholesaler")
        end

        def update_range_extents(range, audience)
          update_columns "#{audience}_lowest_price": range[0],
                         "#{audience}_highest_price": range[1]
        end
      end
    end
  end
end
