Deface::Override.new(
  name: "remove_new_product_available_on",
  virtual_path: "spree/admin/products/new",
  remove: "[data-hook='new_product_available_on']"
)

Deface::Override.new(
  name: "add_new_product_available",
  virtual_path: "spree/admin/products/new",
  insert_after: "[data-hook='new_product_price']",
  text: "
    <div class='col-md-4'>
      <%= f.field_container :available, class: ['form-group'] do %>
        <%= f.label :available, 'Product is available' %>
        <%= f.collection_select :available, [['Available', true], ['Not available', false]], :last, :first, { include_blank: false },  { class: 'form-control' } %>
        <%= f.error_message_on :available %>
      <% end %>
    </div>
  "
)

Deface::Override.new(
  name: "remove_edit_product_available_on",
  virtual_path: "spree/admin/products/_form",
  remove: "[data-hook='admin_product_form_available_on']"
)

Deface::Override.new(
  name: "remove_edit_product_discontinue_on",
  virtual_path: "spree/admin/products/_form",
  remove: "[data-hook='admin_product_form_discontinue_on']"
)

Deface::Override.new(
  name: "add_edit_product_available",
  virtual_path: "spree/admin/products/_form",
  insert_after: "[data-hook='admin_product_form_cost_currency']",
  text: "
    <div class='omega two columns'>
      <%= f.field_container :available, class: ['form-group'] do %>
        <%= f.label :available, 'Product is available' %>
        <%= f.collection_select :available, [['Available', true], ['Not available', false]], :last, :first, { include_blank: false },  { class: 'form-control' } %>
        <%= f.error_message_on :available %>
      <% end %>
    </div>
  "
)
