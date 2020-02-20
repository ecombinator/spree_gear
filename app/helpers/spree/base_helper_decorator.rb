Spree::BaseHelper.module_eval do
  def current_store
    @current_store = Spree::Store.find(ENV.fetch("CURRENT_STORE_ID", Spree::Store.default.id))
  end

  def open_graph_properties
    object = instance_variable_get('@' + controller_name.singularize)
    return {} unless object.is_a?(Spree::Product)
    properties = {}
    properties["og:type"] = "product"
    properties["og:title"] = "#{object.name} | #{current_store.name}"
    properties["og:image"] = image_path image_or_default_for(object, :large)
    description = truncate(strip_tags(object.description), length: 160, separator: ' ')
    description.gsub!(/[\r\n]{2,}/, " ")
    properties["og:description"] = description
    properties["og:keywords"] = object.meta_keywords if object[:meta_keywords].present?
    if properties["og:keywords"].blank? || properties["og:description"].blank?
      if object && object[:name].present?
        properties.reverse_merge!("og:keywords": [object.name, current_store.meta_keywords].reject(&:blank?).join(', '),
                                  "og:description": [object.name, current_store.meta_description].reject(&:blank?).join(', '))
      else
        properties.reverse_merge!("og:keywords": (current_store.meta_keywords || current_store.seo_title),
                                  "og:description": (current_store.meta_description || current_store.seo_title))
      end
    end
    properties
  end

  def open_graph_tags
    open_graph_properties.map do |property, content|
      tag('meta', property: property, content: content) if !(property.nil? || content.nil?)
    end.join("\n")
  end

  def checkout_progress(numbers: false)
    states = @order.checkout_steps
    items = states.each_with_index.map do |state, i|
      text = state_titles(state)
      text = "#{i.succ}" if numbers

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
    @user && @user.identification.blank?
  end
end
