class OrderReportDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :edit_admin_order_path, :number_to_currency, :edit_admin_user_path

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        number: { source: "Spree::Order.number", cond: :like, searchable: true },
        completed_at: { source: "Spree::Order.completed_at", cond: :date_range, searchable: false },
        email: { source: "Spree::Order.email", cond: :like, searchable: true },
        total: { source: "Spree::Order.total", cond: :eq, searchable: false },
        adjustment_total: { source: "Spree::Order.adjustment_total", cond: :eq, searchable: false },
        promo_total: { source: "Spree::Order.promo_total", cond: :eq, searchable: false },
        additional_tax_total: { source: "Spree::Order.additional_tax_total", cond: :eq, searchable: false },
        payment_total: { source: "Spree::Order.payment_total", cond: :eq, searchable: false }
    }
  end

  def data
    return [] unless records
    records.map do |record|
      {
          product_id: humanize_product_ids(record.products),
          number: link_to(record.number, edit_admin_order_path(record.number)),
          completed_at: record.completed_at.to_date.to_formatted_s(:iso8601),
          email: link_to(record.email, edit_admin_user_path(record.user), target: "_blank"),
          referrer: record.user && record.user&.referrer && "##{record.user&.referrer&.rep_name}" || " - ",
          wholesaler: record.user&.wholesaler? && "+w" || "-w",
          total: decimal_to_currency_unit(record.total),
          ship_total: decimal_to_currency_unit(record.ship_total),
          adjustment_total: decimal_to_currency_unit(record.adjustment_total),
          promo_total: decimal_to_currency_unit(record.promo_total),
          additional_tax_total: decimal_to_currency_unit(record.additional_tax_total),
          order_paid: record.paid? && "+p" || "-p",
          paid_max: record.paid? && record.payments.map(&:updated_at).max&.to_date&.to_formatted_s(:iso8601) || "",
          payment_total: record.paid? && number_to_currency(record.payment_total, unit: "") || "",
          shipment_state: record.shipment_state == "shipped" && "+s" || "-s",
          shipped: record.shipped? && record.shipments.map(&:shipped_at).reject(&:nil?).max&.to_date&.to_formatted_s(:iso8601) || ""
      }
    end
  end

  def additional_datas
    filtered_records = filter_records(get_raw_records)
    {
        column_totals: {
            order_total: decimal_to_currency_unit(record_sum(filtered_records, :total)),
            shipping_total: decimal_to_currency_unit(record_sum(filtered_records, :ship_total)),
            adjustment_total: decimal_to_currency_unit(record_sum(filtered_records, :adjustment_total)),
            promo_total: decimal_to_currency_unit(record_sum(filtered_records, :promo_total)),
            additional_tax_total: decimal_to_currency_unit(record_sum(filtered_records, :additional_tax_total)),
            payment_total: decimal_to_currency_unit(record_sum(filtered_records, :payment_total)),
        }
    }
  end

  private


  def record_sum(records, attribute)
    return 0 if records.none?
    records.inject(0) do |total, li|
      value = li.send(attribute)
      total += value ? value : 0
    end
  end

  def decimal_to_currency_unit(number)
    number_to_currency(number, unit: "")
  end

  def get_raw_records
    orders = Spree::Order.joins(:user).
        includes(:payments).references(:payments).
        includes(:shipments).references(:shipments).
        includes(products: :taxons).references(:products).
        where.not( completed_at: nil )
    orders = filter_by_dates(orders)

    if params[:search] && params[:search][:value].present?
      params[:search][:value].scan(/[+\-][wps]/).uniq.each do |state|
        case state
          when "+p"
            orders = orders.where(payment_state: ["paid", "credit_owed"])
          when "-p"
            orders = orders.where.not(payment_state: ["paid", "credit_owed"])
          when "+w"
            orders = Spree::Order.where(id: orders.select{ |x| x.user.wholesaler? }.map(&:id))
          when "-w"
            orders = Spree::Order.where(id: orders.select{ |x| !x.user.wholesaler? }.map(&:id))
          when "+s"
            orders = orders.where(shipment_state: "shipped")
          when "-s"
            orders = orders.where.not(shipment_state: "shipped")
        end
      end
      params[:search][:value] = params[:search][:value].gsub(/[+\-][wps]/, "").gsub(/[+\-]/, "")
    end
    orders.distinct
  end

  def filter_by_dates(orders)
    [:completed, :paid, :shipped].each do |date_field|
      range = date_range_from_search(date_field[0])
      range ||= date_range_from_form(date_field)
      next unless range
      range = range[0].beginning_of_day..range[1].end_of_day
      orders = case date_field
                 when :completed
                   orders.where(completed_at: range)
                 when :paid
                   orders.includes(:payments).where(payment_state: ["paid", "credit_owed"]).
                       where(spree_payments: { updated_at: range })
                 when :shipped
                   orders.includes(:shipments).where(shipment_state: "shipped").
                       where(spree_shipments: { state: "shipped", shipped_at: range })
               end
    end
    orders
  end

  def date_range_from_form(date_field)
    return nil unless params["#{date_field}_at_range"]&.include?(" - ")
    params["#{date_field}_at_range"].split(" - ").map { |s| Date.strptime s }
  end

  def date_range_from_search(date_field_prefix)
    matches = params[:search_value]&.match(/[#{date_field_prefix}]\:([\d]{4}\-[\d]{2}\-[\d]{2})/)
    return unless matches
    date = Date.strptime(matches[0])
    [date, date]
  end

  def humanize_product_ids(products)
    products_count = products.count
    product_ids = ""
    products.each_with_index{ |product, i| product_ids << "##{product.id}#{',' if i != products_count - 1} "}
    product_ids
  end



  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
