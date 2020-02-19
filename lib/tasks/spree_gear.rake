require "pp"

namespace :spree_gear do
  desc "Update product price attributes"
  task update_prices: :environment do
    Spree::Product.available.each &:update_discount_attributes
    Spree::Product.available.each &:update_price_ranges
  end

  desc "Update product availability"
  task update_quantities_sold_last_week: :environment do
    Spree::Variant.all.each &:update_quantity_sold_last_week
    Spree::Variant.all.each &:update_stock_status
  end

  desc "sends mailing to target emails"
  task :send_mailing, [:mailing_id, :email_csv] => :environment do |task, args|
    mailing = Spree::Mailing.find(args.mailing_id)
    count = 0
    File.open(args.email_csv).each do |email|
      puts "Sending to #{email}"
      mailing.send_to!([email.strip])
      count += 1
      break if Rails.env.development?
    end
  end

  desc "Generates missing referral tokens"
  task generate_referral_tokens: :environment do
    before = Spree::User.where(referral_token: nil).count
    Spree::User.where(referral_token: nil).each &:generate_referral_token!
    after = Spree::User.where(referral_token: nil).count
    raise "Task is broken" if after > 0
    puts "Generated #{before - after} tokens"
  end

  desc "Generate referral credits"
  task generate_referral_credits: :environment do
    Spree::Order.joins(:user).
      where(spree_users: { referral_order_id: nil }).
      where.not(spree_users: { referred_by_id: nil }).
      where(payment_state: "paid").each do |order|

      next unless order.user.referral_order_id.nil?
      referrer = Spree::User.find order.user.referred_by_id
      order.user.update! referral_order_id: order.id
      puts "Crediting user ##{referrer.id} for referral of user ##{order.user.id}"
      credit = Spree::StoreCredit.create! user: referrer, memo: "Referral Credit",
                                          amount: ENV.fetch("REFERRAL_CREDIT_AMOUNT", "25.00").to_f,
                                          created_by: Spree::User.first,
                                          category: Spree::StoreCreditCategory.find_by_name("Gift"),
                                          currency: Spree::Store.current.default_currency
      Spree::StoreCreditMailer.referral_credit_notification(credit).deliver_later
    end
  end

  namespace :reports do
    desc "Attmepts to reignite the cache method by rendering the totals partial"
    task visit_totals: :environment do
      include SpreeGear::Base::ViewHelpers::Reports

      puts "visiting totals report"
      ["monthly", "weekly"].each do |interval|
        ["completed", "shipped", "paid"].each do |state|
          totals_interval = interval
          totals_state = state
          totals_variants = false
          totals_ranges = send("#{totals_interval}_ranges")
          totals_cache_expires_in = 24.hours
          Spree::Admin::ReportsController.render(:totals,
                                                 assigns: {
                                                   totals_interval: totals_interval,
                                                   totals_state: totals_state,
                                                   totals_variants: totals_variants,
                                                   totals_ranges: totals_ranges,
                                                   totals_cache_expires_in: totals_cache_expires_in,
                                                 },
                                                 layout: false)
        end
      end
      puts "done visiting totals report"
    end
  end

  namespace :scheduler do
    desc "Remove unavailable items from cart"
    task prune_carts: :environment do
      Spree::Order.where(state: "cart").where("updated_at < ?", 15.minutes.ago).each do |order|
        order.line_items.each do |line_item|
          next unless line_item.variant&.product&.available_on.nil? || (line_item.variant && !line_item.variant.can_supply?)
          puts "Removing variant #{line_item.variant_id} from order #{order.number}"
          line_item.destroy!
          order.persist_totals
        end
      rescue
        puts "Order #{order.id} has corrupted items. Removing."
        order.destroy
      end
    end
  end

  namespace :notifications do
    # eg: to warn customer of orders overdue for more than 48 hours, do: rake "spree_gear:cancel_and_notify_overdue_orders[48]"
    desc "Warns unpaid orders and notifies customers with mailer"
    task :warn_and_notify_overdue_orders, [:time_in_hours] => :environment do |t, args|
      if args.time_in_hours.present?
        Spree::Order.overdue(args.time_in_hours.to_i.hours.ago).map(&:warn_overdue)
      else
        Spree::Order.overdue(24.hours.ago).map(&:warn_overdue)
      end
    end
  end

  # eg: to cancel orders overdue for more than 48 hours, do: rake "spree_gear:cancel_and_notify_overdue_orders[48]"
  desc "Cancels unpaid orders and notifies customers with mailer"
  task :cancel_and_notify_overdue_orders, [:time_in_hours] => :environment do |t, args|
    if args.time_in_hours.present?
      Spree::Order.overdue(args.time_in_hours.to_i.hours.ago).map(&:cancel_overdue_and_notify!)
    else
      # default is 48 hours
      Spree::Order.overdue.map(&:cancel_overdue_and_notify!)
    end
  end
end
