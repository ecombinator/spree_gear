Spree::TaxonsController.class_eval do
  include SpreeGear::Base::ControllerHelpers::Search
  before_action :set_body_id, :set_taxon, :set_products, :set_taxonomies, only: :show

  def show
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
    @gear_search = gear_search(params.merge(taxon: @taxon.id, include_images: true), gear_search_params)
    @products = @gear_search.by_scope(params[:sorting])
    @searcher = @gear_search.base_search
  end

  def set_taxon
    @taxon = Spree::Taxon.friendly.find(params[:id])
    return unless @taxon
  end

  def set_body_id
    @body_id = "taxons-show"
  end
end
