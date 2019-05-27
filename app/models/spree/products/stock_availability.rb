module Spree
  class Product < Spree::Base
    module StockAvailablity
      extend ActiveSupport::Concern
      included do
        def update_availability_status
          update_columns(supply_available: self.can_supply?)
        end
      end
    end
  end
end
