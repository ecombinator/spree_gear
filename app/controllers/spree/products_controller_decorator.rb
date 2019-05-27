Spree::ProductsController.class_eval do
  include SpreeGear::Base::ControllerHelpers::Search
  before_action :confirm_product_access, only: :show
  before_action :set_body_id, :set_products, :set_taxonomies, only: :index

  def show
    @variants = @product.variants_including_master.
      spree_base_scopes.
      active(current_currency).
      includes([:option_values, :images])
    @taxon = params[:taxon_id].present? ? Spree::Taxon.find(params[:taxon_id]) : @product.taxons.first
    respond_to do |format|
      format.html do
        @related_products = @product.related_products.order("RANDOM()").limit(3)
        redirect_if_legacy_path
      end
      format.js {}
    end
  end

  def index
    respond_to do |format|
      format.html {}
      format.js {}
      format.json {
        render json: [view_context.products_to_json(@products, true),
        {
          products_current_page:  @products.current_page,
          total_pages: @products.total_pages,
          products_count: @products.total_count

        }].to_json
      }
    end
  end

  private

  def gear_search_params
    properties = {}
    properties[:whitelist_page_count] = [Spree::Config[:products_per_page]]
    properties[:check_possible_promotions] = true
    properties[:check_sold_to] = true
    properties[:currency] = Spree::Config[:currency]
    properties
  end

  def set_taxonomies
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end

  def set_products
    @gear_search = gear_search(params.merge(include_images: true), gear_search_params)
    @searcher = @gear_search.base_search
    @products =  @gear_search.by_scope(params[:sorting])
  end

  def confirm_product_access
    @product.variants_and_option_values(current_currency).any?
  end

  def set_body_id
    @body_id = "products-index"
  end
end
