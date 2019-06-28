# frozen_string_literal: true

require Rails.root.join("lib/weight_converter")

Spree::Variant.instance_eval do
  scope :with_active_product, -> {
    joins(:product).where("#{Spree::Product.quoted_table_name}.deleted_at IS NULL AND #{Spree::Product.quoted_table_name}.available_on IS NOT NULL")
        .where("#{Spree::Product.quoted_table_name}.discontinue_on IS NULL or #{Spree::Product.quoted_table_name}.discontinue_on >= ?", Time.zone.now)
  }

  scope :discontinued_products, -> {
    joins(:product).where.not(spree_products: {discontinue_on: nil})
  }

  scope :sold_to_consumers, (-> { where sold_to_consumers: true })
  scope :sold_to_wholesalers, (-> { where sold_to_wholesalers: true })

  scope :by_category_name, -> (category_name) {
    joins(product: :taxons).where("lower(spree_taxons.name) = ?", category_name.downcase)
  }

  after_update :update_master_visibility, unless: :is_master?
  after_save :update_product_price_ranges
end

Spree::Variant.class_eval do
  delegate :flower?, to: :product

  after_save :update_options_hash

  def on_backorder
    inventory_units.with_state('backordered').size
  end

  def total_stock
    total_committed + total_on_hand
  end

  def total_committed
    Spree::LineItem.joins(:variant).joins(:order).where(variant_id: id).
        where(spree_orders: { state: "complete" }).
        where.not(spree_orders: { shipment_state: "shipped" }).sum(&:quantity).to_i
  end

  def update_stock_status
    previously_stocked = stocked_for_the_week
    currently_stocked = total_on_hand - on_backorder
    update stocked_for_the_week: currently_stocked > (quantity_sold_last_week * 1.2).ceil
    product.update_stock_status if previously_stocked != currently_stocked
  end

  def update_quantity_sold_last_week
    self.update_column :quantity_sold_last_week,
                       Spree::LineItem.where(variant_id: id).joins(:order)
                           .where(created_at: [7.days.ago..Time.current.beginning_of_day])
                           .where(variant_id: id, spree_orders: { state: "complete" })
                           .sum(:quantity)
  end

  def revenue_last_week
    Rails.cache.fetch("variant/#{id}/revenue_last_week", expires_in: 24.hours) do
      Spree::LineItem.sold
          .where(variant_id: id)
          .where(created_at: [7.days.ago..Time.current.beginning_of_day])
          .sum(:price)
    end
  end

  def revenue_last_30_days
    Rails.cache.fetch("variant/#{id}/revenue_last_30_days", expires_in: 24.hours) do
      Spree::LineItem
          .sold
          .where(variant_id: id)
          .where(created_at: [31.days.ago..Time.current.beginning_of_day])
          .sum(:price)
    end
  end

  def revenue_between_days(date_range, order_scope)
    hash = Digest::SHA1.base64digest(date_range.to_s + order_scope.to_s)
    Rails.cache.fetch("variant/#{id}/revenue_between_days/#{hash}", expires_in: 24.hours) do
      Spree::LineItem.sold
          .joins(:order)
          .merge(order_scope)
          .where(variant_id: id)
          .where(created_at: date_range)
          .sum(:price)
    end
  end

  def short_descriptive_name
    is_master? ? name : name + " - " + short_options_text
  end

  def non_weight_options_text
    values = non_weight_option_values.joins(:option_type).order("spree_option_types.position")
    return nil unless values.any?
    values = values.to_a.map { |ov| ov.presentation.to_s }
    values.to_sentence(words_connector: ", ", two_words_connector: ", ")
  end

  def short_options_text
    values = option_values.joins(:option_type).order("spree_option_types.position")
    values.to_a.map! { |ov| ov.presentation.to_s }
    values.to_sentence(words_connector: ", ", two_words_connector: ", ")
  end

  def wholesale_price_or_default
    wholesale_price ? wholesale_price : price
  end

  def wholesale_price_or_nil
    wholesale_price ? wholesale_price : nil
  end

  def wholesale_price=(value)
    value.gsub!(/[^\d\.]/, '') if value.is_a?(String)
    super(value)
  end

  def update_master_visibility
    return unless product
    ["consumers", "wholesalers"].each do |audience|
      audience = "sold_to_#{audience}".to_sym
      product.master.update_column audience, product.variants.any?(&audience)
    end
  end

  def update_product_price_ranges
    product.update_price_ranges
  end

  def siblings
    return [] if is_master?
    product.variants.where("id <> ?", id)
  end

  def units_text(count)
    if weight_option_value
      " #{weight_option_value.presentation.downcase.pluralize(count).gsub('ounce', 'oz').gsub('ozs', 'oz')}"
    else
      ""
    end
  end

  def is_lightest_or_master?
    is_master? || is_lightest_variant?
  end

  def is_lightest_variant?
    product.lightest_variant == self
  end

  def is_heaviest_variant?
    product.heaviest_variant == self
  end

  def short_options_text
    option_values.sort { |a, b| a.option_type.position <=> b.option_type.position }
        .to_a.map!(&:presentation)
        .to_sentence(words_connector: ", ", two_words_connector: ", ")
  end

  def convert_units_to(units, to_variant = product.lightest_variant)
    unless weight_option_value && to_variant.weight_option_value
      raise ArgumentError, "Both Variants must have a weight Option."
    end
    (units * weight_in_grams) / to_variant.weight_in_grams
  end

  def short_descriptive_name
    is_master? ? name : name + " - " + short_options_text
  end

  def weight_in(units)
    return if weight_option_value.nil?
    WeightConverter.new(weight_option_value.name, units).scolar
  end

  def weight_in_grams
    weight_in("g").try { |o| o.round 1 }
  end

  def non_weight_option_values
    option_values.where.not(option_type_id: Spree::OptionType.find_by_name("Weight"))
  end

  def weight_option_value
    option_values.where(option_type_id: Spree::OptionType.find_by_name("Weight")).first
  end

  # TODO-AM default_weight_price and default_cost are only called from product
  # they should be product private methods
  def default_weight_cost
    return nil if product.cost_price.nil?
    master_cost = product.cost_price

    if weight_option_value.nil?
      master_cost
    else
      fractional_cost = weight_in("oz") * master_cost
      fractional_cost.to_f
    end
  end

  def default_weight_price
    master_price = product.price_in(Spree::Config[:currency]).amount

    if weight_option_value.nil?
      master_price
    else
      fractional_price = weight_in("oz") * master_price
      fractional_price.to_f
    end
  end

  def update_options_hash
    text = non_weight_options_text
    update_column :options_hash, text ? Digest::SHA1.hexdigest(non_weight_options_text) : nil
  end
end
