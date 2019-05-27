Spree::Core::Search::Base.class_eval do
  def get_base_scope
    base_scope = Spree::Product.spree_base_scopes.active
    # overrides the original taxon searcher because eagerloaded scopes wont work on it
    unless taxon.blank?
      base_scope = base_scope.joins(:taxons).where(spree_taxons: {id: taxon.id})
    end
    base_scope = get_products_conditions_for(base_scope, keywords)
    base_scope = add_search_scopes(base_scope)
    base_scope = add_eagerload_scopes(base_scope)
    base_scope
  end
end
