Spree::Address.class_eval do
  before_save :upcase_zipcode

  def require_phone?
    false
  end

  def self.from_woo(woo_user)
    address = Spree::Address.new
    address.country = Spree::Country.find_by_name("Canada")
    address.city = woo_user["city"]
    address.state = Spree::State.find_all_by_name_or_abbr( woo_user["state"]).first
    address.first_name = woo_user["first_name"]
    address.last_name = woo_user["last_name"]
    address.address1 = woo_user["address_1"]
    address.address2 = woo_user["address_2"]
    address.zipcode = woo_user["postcode"]
    address
  end

  def upcase_zipcode
    return if zipcode.nil?
    return if zipcode =~ /[A-Z][0-9][A-Z] [0-9][A-Z][0-9]/
    self.zipcode = zipcode.to_s.upcase.sub(/ /, "")
    self.zipcode = zipcode.insert(3, " ") if zipcode.length == 6
  end
end
