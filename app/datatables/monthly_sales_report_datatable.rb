class MonthlySalesReportDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :link_to, :number_to_currency

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      name: { source: "Spree::Taxon.name", cond: :like, searchable: true }
    }
  end

  def data
    records.map do |record|
      hash = {
        name: record.name,
        past_30_days: number_to_currency(get_line_items_by(record.name).
            where(spree_orders: {completed_at: (30.days.ago..Time.now)}).
            inject(0) { |total, li| total += li.pre_tax_amount }, precision: 0)
      }
      (1..months_back).each do |number|
        hash["month_#{number}".to_sym] = number_to_currency(get_line_items_by(record.name).
            where(spree_orders: {completed_at: monthly_range(number)}).
            inject(0) { |total, li| total += li.pre_tax_amount }, precision: 0)
      end
      hash
    end
  end

  def additional_datas

    hash = {
      column_totals: {
        past_30_days: number_to_currency(Spree::Order.paid.where(completed_at: 30.days.ago..Time.now).sum(:total), precision: 0),
      }
    }

    (1..months_back).each do |number|
      hash[:column_totals]["month_#{number}".to_sym] = number_to_currency(
          Spree::Order.paid.where(completed_at: monthly_range(number)).sum(:total), precision: 0)
    end
    hash
  end

  private

  def months_back
    ENV.fetch("REPORT_MONTHS", 3).to_i
  end

  def get_raw_records
    Spree::Taxon.leaf_categories
  end

  def get_line_items_by(taxon_name, line_items = nil)
    line_items ||= Spree::LineItem.all
    line_items = line_items.joins(:order).
        where(spree_orders: { payment_state: ["paid", "credit_owed"] })
    line_items = line_items.by_product_category_name(taxon_name)
    line_items.distinct
  end

  def monthly_range(month_number)
    last = (Time.now - month_number.month)
    (last.beginning_of_month..last.end_of_month)
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
