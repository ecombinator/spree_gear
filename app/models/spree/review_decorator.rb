Spree::Review.class_eval do
  scope :highest_rating, -> { order(rating: :desc) }
end
