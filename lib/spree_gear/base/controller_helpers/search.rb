module SpreeGear
  module Base
    module ControllerHelpers
      module Search
        def gear_search(params, gear_params = {})
          SpreeGear::Base::Search.new(params, gear_params, try_spree_current_user)
        end
      end
    end
  end
end
