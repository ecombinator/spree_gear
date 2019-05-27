Deface::Override.new(
  virtual_path: "spree/layouts/admin",
  name: "home_category_sidebar_menu",
  insert_bottom: "#main-sidebar",
  partial: "spree/admin/shared/home_settings_menu"
)
