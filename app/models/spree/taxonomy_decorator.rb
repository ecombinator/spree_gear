module Spree
  Taxonomy.class_eval do
    def self.categories_with_children
      find_by(name: "Category").taxons.where.not(name: "Category")
    end

    def self.category_names
      Rails.cache.fetch("category_names", expires_in: 15.minutes) do
        categories_with_children.map { |category| category.name.downcase }
      end
     end

    def self.category_names_with_children
      Rails.cache.fetch("category_names_with_children", expires_in: 15.minutes) do
        categories_with_children.map do |category|
          [
            category.name.downcase,
            category.children.map { |child| child.name.downcase }
          ]
        end.flatten
      end
    end

    def self.is_category_word_pure?(word)
      category_names_with_children.include?(word.downcase)
    end

    def self.is_category_pure?(words)
      category_list = category_names
      words.downcase.split(" ").each do |word|
        return false unless category_list.include?(word)
      end
      true
    end

    def self.find_categories_from(words)
      category_list = category_names
      words_categories = Array.new
      words.downcase.split(" ").each do |word|
      words_categories << word if category_list.include?(word.downcase)
      end
      if words_categories.present?
        words_categories
      else
        false
      end
    end
  end
end
