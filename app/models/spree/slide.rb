module Spree
  class Slide < Base
    belongs_to :slider

    scope :disabled, (->{ where disabled: true })
    scope :enabled, (->{ where disabled: false })

    has_attached_file :picture, styles: { thumb: "100x100>" }
    validates_attachment_content_type :picture, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  end
end
