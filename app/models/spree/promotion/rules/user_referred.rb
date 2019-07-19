module Spree
  class Promotion
    module Rules
      class UserReferred < PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          order.user.referred_by_id.present?
        end

        def actionable?(line_item)
          true
        end
      end
    end
  end
end
