module SpreeGear
  module Base
    module ControllerHelpers
      module Global
        def enforce_staging_authentication
          if Rails.env.staging? && staging_username && staging_password
            authenticate_or_request_with_http_basic do |user, pass|
              user == ENV.fetch("STAGING_USERNAME") && pass == ENV.fetch("STAGING_PASSWORD")
            end
          end
        end

        def staging_username
          ENV.fetch("STAGING_USERNAME") { false }
        end

        def staging_password
          ENV.fetch("STAGING_PASSWORD") { false }
        end

        def wholesale?
          @wholesale ||= spree_current_user&.wholesaler?
        end
      end
    end
  end
end
