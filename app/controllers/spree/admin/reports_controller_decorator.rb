# frozen_string_literal: true

# app/controllers/spree/admin/reports_controller_decorator.rb

require_dependency "spree/admin/reports_controller"

Spree::Admin::ReportsController.class_eval do
  include SpreeGear::Base::ViewHelpers::Reports

  before_action :set_default_date_range, only: [:order_detail, :line_item_detail]

  add_available_report! :reps
  add_available_report! :vips
  add_available_report! :totals
  add_available_report! :order_detail
  add_available_report! :line_item_detail

  def order_detail
    respond_to do |format|
      format.html
      format.json { render json: OrderReportDatatable.new(view_context) }
    end
  end

  def line_item_detail
    respond_to do |format|
      format.html
      format.json { render json: LineItemReportDatatable.new(view_context) }
    end
  end

  def reps
    @reps = Spree::Role.find_by_name("sales_rep").users.select { |u| u.rep_name.present? }
    @reps = @reps.sort_by &:rep_name
  end

  def vips
    @users = Spree::User.vips
  end

  def totals
    @totals_interval = params[:interval].to_s.empty? ? "daily" : params[:interval]
    @totals_state = params[:state].to_s.empty? ? "shipped" : params[:state]
    @totals_variants = params[:variants].to_s.empty? ? false : params[:variants] == "true"
    @totals_ranges = send("#{@totals_interval}_ranges")
    @totals_cache_expires_in = @totals_interval == "daily" ? 15.minutes : 24.hours

    respond_to do |format|
      format.html
    end
  end

  private

  def set_default_date_range
    return if [:completed_at_range, :paid_at_range, :shipped_at_range].any? {|p| params[p].present? }
    yesterday = 1.day.ago.to_date.to_s
    params[:completed_at_range] = "#{yesterday} - #{yesterday}"
  end
end
