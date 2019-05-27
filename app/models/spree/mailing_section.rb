module Spree
  class MailingSection < Base
    belongs_to :mailing, inverse_of: :sections

    has_attached_file :image,
                      styles: { medium: "1024x1024>" },
                      default_url: "/images/:style/missing.png"
    validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

    def geo
      @geo ||= Paperclip::Geometry.from_file(image.path)
    end

    def image_width
      geo.width
    end

    def image_height
      geo.height
    end
  end
end
