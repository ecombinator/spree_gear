Spree::User.class_eval do
  include Spree::UserMethods

  devise :lockable

  before_save :assign_role_attributes
  after_update :notify_of_approval

  has_many :referred_users, class_name: "Spree::User", foreign_key: :referred_by_id
  has_many :notifications
  has_one :mailing_recipient, class_name: "Spree::MailingRecipient", foreign_key: :spree_user_id
  belongs_to :referrer, class_name: "Spree::User", foreign_key: :referred_by_id

  has_attached_file :identification,
                    styles: { medium: "300x300>", thumb: "100x100>" },
                    default_url: "/images/:style/missing.png"

  validates_attachment_content_type :identification, content_type: /\Aimage\/.*\z/

  scope :approved, -> { where(patient: true) }
  scope :unapproved, -> { where.not(patient: true)}
  scope :sales_reps, -> { where(sales_rep: true) }
  scope :wholesalers, -> { where.not(company: nil) }

  def self.named_sales_reps
    sales_reps.select { |u| u.rep_name.present? }
  end

  def self.vips
    Rails.cache.fetch "users/vips", expires_in: 15.minutes do
      Spree::User.all.sort_by(&:lifetime_value)[-25..-1]
    end.try(:reverse)
  end

  def self.from_woo(woo_user)
    return unless woo_user
    if Spree::User.where( "email ILIKE ?", woo_user["email"].strip).any?
      user = Spree::User.where( "email ILIKE ?", woo_user["email"].strip).first
    end
    user ||= Spree::User.new
    user.name = woo_user["first_name"] unless woo_user["first_name"].empty?
    user.email = woo_user["email"].strip
    user.password = woo_user["password"]
    user.password ||= SecureRandom.base64(12)
    user.save!

    unless woo_user["address_1"].empty?
      address = Spree::Address.from_woo(woo_user)
      if address.save
        user.addresses << address
        user.ship_address = address
        user.bill_address = address
        user.save
      end
    end

    user.spree_roles << Spree::Role.find_by_name("user")
    user.spree_roles << Spree::Role.find_by_name("patient")
    user.spree_roles << Spree::Role.find_by_name("admin") if woo_user["roles"].include?("administrator")
    user
  end

  def lifetime_value
    orders.paid.sum(&:total)
  end

  def rep_name
    ship_address&.first_name || email.split("@")[0]
  end

  def wholesaler?
    !company.nil? || has_spree_role?("wholesaler") || has_spree_role?("wholesaler-candidate")
  end

  def superadmin?
    has_spree_role?("superadmin")
  end

  def shipping_admin?
    has_spree_role?("shipping_admin")
  end

  def approved?
    patient?
  end

  def send_approval_email
    Spree::UserMailer.approval_email(self).deliver_now
  end

  def referred_orders
    Spree::Order.where(user_id: referred_users)
  end

  def assign_role_attributes
    assign_attributes \
                  patient: has_spree_role?("patient"),
                  admin: has_spree_role?("admin"),
                  sales_rep: has_spree_role?("sales_rep")
  end

  def notify_of_approval
    return if spree_api_key.present?
    return unless has_spree_role?("patient") || has_spree_role?("wholesaler")
    if has_spree_role?("wholesaler")
      spree_roles.find_by_name("wholesaler-candidate")&.destroy
    end
    Spree::UserMailer.approval_granted_email(self.id).deliver_now
    generate_spree_api_key!
  end
end

require "spree_gear/importers/user_importer"
