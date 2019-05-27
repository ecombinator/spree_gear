Spree::BaseHelper.module_eval do

  def current_store
    @current_store = Spree::Store.find(ENV.fetch("CURRENT_STORE_ID", Spree::Store.default.id))
  end

  def checkout_progress(numbers: false)
    states = @order.checkout_steps
    items = states.each_with_index.map do |state, i|
      text = state_titles(state)
      text = ("#{i.succ}") if numbers

      css_classes = []
      current_index = states.index(@order.state)
      state_index = states.index(state)

      css_classes << "stepwizard-step "
      css_classes << "next" if state_index == current_index + 1
      css_classes << "active" if state == @order.state
      css_classes << "first" if state_index == 0
      css_classes << "last" if state_index == states.length - 1
      "<li class=\"#{css_classes.join(" ")}\">
        <a class=\"btn btn-default\">
          #{i.succ}
        </a>
        <div>
          <small>#{text}</small>
        </div>
      </li>"
    end
    content_tag("ul", raw(items.join("\n")), class: "progress-steps", id: "checkout-step-#{@order.state}")
  end

  def this_month_range
    (Time.now.beginning_of_month..Time.now)
  end

  def last_month_range
    last = (Time.now - 1.month)
    (last.beginning_of_month..last.end_of_month)
  end

  def two_months_ago_range
    last = (Time.now - 2.month)
    (last.beginning_of_month..last.end_of_month)
  end

  def masquerading?
    session[:admin_id]
  end

  def sold_to_current_user?(product_or_variant)
    return true if try_spree_current_user.try(:admin?)
    return product_or_variant.sold_to_wholesalers if try_spree_current_user.try(:wholesaler?)
    product_or_variant.sold_to_consumers
  end

  def state_titles(state)
    if state == "complete"
      "Review"
    else
      state.titleize
    end
  end

  alias_method :old_display_price, :display_price

  def display_price(product_or_variant)
    if wholesale? && product_or_variant.wholesale_price
      number_to_currency(product_or_variant.wholesale_price)
    else
      old_display_price(product_or_variant)
    end
  end

  def product_categories
    category_taxon = Spree::Taxonomy.find_by_name("Category")
    category_taxon && category_taxon.taxons.where(depth: 1).order(:name) || []
  end

  def needed_for_free_shipping(order)
    minimum_shipping_amount - order.total + order.shipment_total
  end

  def current_user_unidentified?
    @user && !@user.identification.present?
  end
end
