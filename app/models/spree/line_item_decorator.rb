Spree::LineItem.class_eval do
  scope :by_product_category_name, -> (category_name) {
    joins(product: :taxons).where("lower(spree_taxons.name) = ?", category_name.downcase) }

  scope :in_taxons, -> (taxons) {
    joins(product: :taxons).where("spree_taxons.id IN (?)", (taxons.respond_to?(:uniq) ? taxons.uniq : taxons)).distinct }

  scope :not_in_taxons, (-> (taxon_ids) { where("spree_line_items.id NOT IN (?)", in_taxons(taxon_ids).map(&:id)) })

  scope :paid, (-> { joins(:order).where(spree_orders: { payment_state: ["paid", "credit_owed"] }) })

  gear_copy_price = instance_method(:copy_price)

  define_method(:copy_price) do
    gear_copy_price.bind(self).call
    return unless variant

    prices = []
    prices << price if price.present?
    prices << variant.volume_price(quantity, order.user)
    prices << variant.wholesale_price_or_default if order.wholesale?
    prices = prices.uniq.reject(&:nil?)

    self.price = prices.min.to_d
    self.cost_price = variant.cost_price if cost_price.nil?
    self.currency = variant.currency if currency.nil?
  end

  def profit_amount
    [ payment_amount- cost_price.to_f, 0].max
  end

  def payment_amount
    [ order.payment_total.to_f / order.total.to_f, 1.0].min * pre_tax_amount.to_f
  end

  def cart_display_price(view_context)
    view_context.number_to_currency price
  end

  def cart_price_total(view_context)
      view_context.number_to_currency(price * quantity)
  end
end
