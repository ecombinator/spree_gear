# frozen_string_literal: true

Spree::Image.class_eval do
  attr_reader :attachment_remote_url

  has_attached_file :attachment,
#                    path: ":class/:attachment/:id/:style.:extension",
                    styles: {
                      mini: ["48x48>", :jpeg],
                      small: ["100x100>", :jpeg],
                      product: ["240x240>", :jpeg],
                      large: ["600x600>", :jpeg]
                    },
                    default_style: :product,
                    convert_options: {
                      all: "-strip -interlace Plane -quality 80 -colorspace sRGB"
                    }

  def attachment_remote_url=(url_value)
    self.attachment = URI.parse(url_value)
    # Assuming url_value is http://example.com/photos/face.png
    # avatar_file_name == "face.png"
    # avatar_content_type == "image/png"
    @attachment_remote_url = url_value
  end
end

Spree::Image.instance_eval do
  def self.accepted_image_types
    ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
  end
end
