module Spree
  class ShippingLabel
    PAGE_WIDTH = 508
    FONT_SIZE = 16
    PAGE_HEIGHT = 191
    MARGIN = 15

    def initialize(shipments)
      @pdf = Prawn::Document.new(
          page_size: [PAGE_HEIGHT, PAGE_WIDTH],
          optimize_objects: true,
          page_layout: :landscape,
          margin: [MARGIN, MARGIN]
      )
      @font_size = ((PAGE_HEIGHT - MARGIN).to_f/5)

      shipments.each_with_index do |shipment, index|
        @pdf.start_new_page if index > 0
        add_recipient shipment.order.ship_address
      end
    end

    def add_recipient(address)
      @pdf.move_cursor_to @pdf.bounds.top
      @pdf.font_size @font_size
      @pdf.indent(1) do
        @pdf.text "<b>#{address.full_name}</b>", inline_format: true
        @pdf.text address.address1
        @pdf.text address.address2 if address.address2
        @pdf.text "#{address.city}, #{address.state.abbr} <b>#{address.zipcode.upcase}</b>", inline_format: true
      end
    end

    def render
      @pdf.render
    end
  end
end

