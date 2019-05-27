# frozen_string_literal: true

Spree::Admin::ProductsController.class_eval do
  before_action :add_available_to_permitted_resources

  def update
    if params[:product][:taxon_ids].present?
      params[:product][:taxon_ids] = params[:product][:taxon_ids].split(',')
    end
    if params[:product][:option_type_ids].present?
      params[:product][:option_type_ids] = params[:product][:option_type_ids].split(',')
    end
    invoke_callbacks(:update, :before)
    sanitize_tags
    if @object.update_attributes(permitted_resource_params)
      invoke_callbacks(:update, :after)
      flash[:success] = flash_message_for(@object, :successfully_updated)
      respond_with(@object) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render layout: false }
      end
    else
      # Stops people submitting blank slugs, causing errors when they try to
      # update the product again
      @product.slug = @product.slug_was if @product.slug.blank?
      invoke_callbacks(:update, :fails)
      respond_with(@object)
    end
  end

  private

  def sanitize_tags
    new_tags = permitted_resource_params['tag_list'].split(",").reject { |c| c.empty? }
    old_tags = @product.tags.map(&:name)
    return if new_tags == old_tags
    (old_tags - new_tags).map {|e| @product.tag_list.remove(e)}
    (new_tags - old_tags ).map {|e| @product.tag_list.add e}
  end

  def add_available_to_permitted_resources
    Spree::PermittedAttributes.product_attributes.push(:available)
  end


  def collection
    return @collection if @collection.present?
    params[:q] ||= {}
    params[:q][:deleted_at_null] ||= "1"
    params[:q][:not_discontinued] ||= "1"

    params[:q][:s] ||= "name asc"
    @collection = super
    # Don't delete params[:q][:deleted_at_null] here because it is used in view to check the
    # checkbox for 'q[deleted_at_null]'. This also messed with pagination when deleted_at_null is checked.
    if params[:q][:deleted_at_null] == '0'
      @collection = @collection.with_deleted
    end
    # @search needs to be defined as this is passed to search_form_for
    # Temporarily remove params[:q][:deleted_at_null] from params[:q] to ransack products.
    # This is to include all products and not just deleted products.

    if params[:q][:name_cont].present? && Spree::Taxonomy.is_category_word_pure?(params[:q][:name_cont])
      @search = @collection.joins(:taxons).where("lower(spree_taxons.name) = ?", params[:q][:name_cont].downcase).ransack(params[:q])
      @collection = @collection.joins(:taxons).where("lower(spree_taxons.name) = ?", params[:q][:name_cont].downcase)

    else
      @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })
      @collection = @search.result.
          distinct_by_product_ids(params[:q][:s]).
          includes(product_includes)
    end

    if params[:availability] == "1"
      @collection = @collection.available
    elsif params[:availability] == "0"
      @collection = @collection.not_available
    end

    @collection = @collection.page(params[:page]).per(params[:per_page] || Spree::Config[:admin_products_per_page])
  end
end
