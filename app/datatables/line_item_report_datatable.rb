class LineItemReportDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :edit_admin_order_path, :number_to_currency

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
        product_name: { source: "Spree::Product.name", cond: :like, searchable: true },
        taxon_name: { source: "Spree::Taxon.name", cond: :like, searchable: true },
        number: { source: "Spree::Order.number", cond: :like, searchable: true },
        completed_at: { source: "Spree::Order.completed_at", cond: :date_range, searchable: false },
        adjustment_total: { source: "Spree::LineItem.adjustment_total", cond: :eq, searchable: false },
        pre_tax_amount: { source: "Spree::LineItem.pre_tax_amount", cond: :eq, searchable: false },
        cost_price: { source: "Spree::LineItem.cost_price", cond: :eq, searchable: false },
        payment_amount: { source: "Spree::LineItem.payment_amount", cond: :eq, searchable: false },
        profit_amount: { source: "Spree::LineItem.profit_amount", cond: :eq, searchable: false },
    }
  end

  def data
    records.map do |record|
      {
          product_name: record.variant&.short_descriptive_name || "DELETED",
          taxon_name: record.variant&.product&.taxons&.last&.name || "N/A",
          number: link_to(record.order.number, edit_admin_order_path(record.order.number)),
          completed_at: record.order.completed_at.to_date.to_formatted_s(:iso8601),
          payment_state: record.order.paid? && "+p" || "-p",
          shipment_state: record.order.shipment_state == "shipped" && "+s" || "-s",
          adjustment_total: decimal_to_currency_unit(record.adjustment_total),
          pre_tax_amount: decimal_to_currency_unit(record.pre_tax_amount),
          cost_price: decimal_to_currency_unit(record.cost_price),
          payment_amount: decimal_to_currency_unit(record.payment_amount),
          profit_amount: decimal_to_currency_unit(record.profit_amount)
      }
    end
  end

  def additional_datas
    filtered_records = filter_records(get_raw_records)
    {
        column_totals: {
            adjustment_total: decimal_to_currency_unit(record_sum(filtered_records, :adjustment_total)),
            pre_tax_total: decimal_to_currency_unit(record_sum(filtered_records, :pre_tax_amount)),
            cost_total: decimal_to_currency_unit(record_sum(filtered_records, :cost_price)),
            payment_total: decimal_to_currency_unit(record_sum(filtered_records, :payment_amount)),
            profit_total: decimal_to_currency_unit(record_sum(filtered_records, :profit_amount))
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
    line_items = Spree::LineItem.
        joins(variant: :product).
        joins(order: :user).where.not(spree_orders: { completed_at: nil }).
        includes(product: :taxons).references(:taxons)

    line_items = filter_by_category(line_items) if params[:category].present?
    line_items = filter_by_dates(line_items)

    if params[:search] && params[:search][:value].present?
      params[:search][:value].scan(/[+\-][wps]/).uniq.each do |state|
        case state
          when "+p"
            line_items = line_items.where(spree_orders: { payment_state: ["paid", "credit_owed"] })
          when "-p"
            line_items = line_items.where.not(spree_orders: { payment_state: ["paid", "credit_owed"] })
          when "+s"
            line_items = line_items.where(spree_orders: { shipment_state: "shipped" })
          when "-s"
            line_items = line_items.where.not(spree_orders: { shipment_state: "shipped" })
          else
            line_items
        end
      end
      params[:search][:value] = params[:search][:value].gsub(/[+\-][wps]/, "").gsub(/[+\-]/, "")
    end
    line_items
  end

  def filter_by_category(line_items)
    line_items.by_product_category_name(params[:category])
  end

  def filter_by_dates(line_items)
    [:completed, :paid, :shipped].each do |date_field|
      range = date_range_from_search(date_field[0])
      range ||= date_range_from_form(date_field)
      next unless range
      range = range[0].beginning_of_day..range[1].end_of_day
      line_items = case date_field
                     when :completed
                       line_items.where(spree_orders: { completed_at: range })
                     when :paid
                       line_items.
                           includes(order: :payments).
                           where(spree_orders: { payment_state: ["paid", "credit_owed"] }).
                           where(spree_payments: { updated_at: range })
                     when :shipped
                       line_items.
                           includes(order: :shipments).
                           where(spree_orders: { shipment_state: "shipped" }).
                           where(spree_shipments: { state: "shipped", shipped_at: range })
                   end
    end
    line_items
  end

  def date_range_from_form(date_field)
    return nil unless params["#{date_field}_at_range"]&.include?(" - ")
    range = params["#{date_field}_at_range"].split(" - ").map { |s| Date.strptime s }
    range
  end

  def date_range_from_search(date_field_prefix)
    matches = params[:search_value]&.match(/[#{date_field_prefix}]\:([\d]{4}\-[\d]{2}\-[\d]{2})/)
    return unless matches
    date = Date.strptime(matches[0])
    [date, date]
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
