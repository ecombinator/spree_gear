# This library is intended to secure parameters + helpers before going to spree_Search -jib

# variables used for gear_params

# gear_params[:whitelist_page_count] - (array), for whitelisted per_page numbers, eg: [12, 24]
# gear_params[:check_possible_promotions] - (bool), true if there are any promotions used
# gear_params[:check_sold_to] - (bool), true allowing sold_to to current_user
# gear_params[:currency] - (string), the current currency used
# gear_params[:wholesaler_default] - (bool), true if defaults to wholesaler products when no user is logged in

module SpreeGear
  module Base
    class Search
      attr_accessor :current_user
      attr_accessor :products

      attr_accessor :base_search

      def initialize(assigned_params, gear_params = {}, current_user = nil)
        if assigned_params[:per_page].present?
          assigned_params[:per_page] = set_per_page(
            gear_params[:whitelist_page_count],
            assigned_params[:per_page]
          )
        end
        @products = initiate_search(assigned_params, gear_params, current_user)
      end

      def category_count
        @products.category_count
      end

      def by_scope(sorting_scope)
        sorting_scope = sorting_scope.try(:to_sym) || :default
        if Spree::Product.whitelisted_search_scope?(sorting_scope)
          @products.send(sorting_scope)
        else
          @products
        end
      end

      def price_range
        return [0, 0] unless @products.any?
        if current_user.present? && current_user.wholesaler?
          @products.lowest_and_highest_wholesaler_prices.map { |g| g.to_i }
        else
          @products.lowest_and_highest_consumer_prices.map { |g| g.to_i }
        end
      end

      private

      def initiate_search(assigned_params, gear_params, current_user)
        searcher = Spree::Config.searcher_class.new(assigned_params).tap do |searcher|
          searcher.current_user = current_user
          searcher.current_currency = gear_params[:currency]
        end
        @base_search = searcher
        products = searcher.retrieve_products
        products = apply_filters(products, assigned_params)
        if gear_params[:check_possible_promotions].present? && products.respond_to?(:includes)
          products = products.includes(:possible_promotions)
        end
        if gear_params[:check_sold_to].present? && current_user.present?
          if current_user.wholesaler?
            products = products.sold_to_wholesalers
          elsif current_user.admin?
            products = products
          else
            products = products.sold_to_consumers
          end
        else
          if gear_params[:wholesale_default].present?
            products = products.sold_to_wholesalers
          else
            products = products.sold_to_consumers
          end
        end
        products
      end

      def set_per_page(whitelisted_page_counts, page_count)
        page_count = page_count.to_i
        if whitelisted_page_counts.blank? || page_count.blank?
          return Spree::Config[:products_per_page]
        end
        if whitelisted_page_counts.include?(page_count)
          page_count
        else
          Spree::Config[:products_per_page]
        end
      end

      # Filters

      def apply_filters(products, params)
        return products unless products.any? && params[:filters].present?

        products = filter_categories(products, params)
        filter_price_range(products, params)
      end

      def filter_categories(products, params)
        return products if params[:filters][:selected_categories].blank?
        selected_categories = selected_categories(params)
        return products unless selected_categories&.any?
        products.in_taxons(selected_categories)
      end

      def selected_categories(params)
        @selected_categories = params[:filters][:selected_categories]
        return @selected_categories if params[:taxon].blank?
        taxon_name = Spree::Taxon.find(params[:taxon])&.name
        @selected_categories.reject! { |st| st == taxon_name }
      end

      def filter_price_range(products, params)
        return products if params[:filters][:variant_prices_between].blank?
        if current_user.present? && current_user.wholesaler?
          products = products.variant_prices_between_wholesaler(
            params[:filters][:variant_prices_between][0],
            params[:filters][:variant_prices_between][1]
          )
        else
          products = products.variant_prices_between(
            params[:filters][:variant_prices_between][0],
            params[:filters][:variant_prices_between][1]
          )
        end
        products
      end
    end
  end
end
