class WeightConverter
  attr_accessor :text, :units

  def initialize text, units
    @text = text
    @units = units
  end

  def scolar
    text.sub! "½", "0.5"
    text.sub! "¼", "0.25"
    text.sub! "⅛", "0.125"
    text.gsub! "/half/i", "0.25"
    text.gsub! "/quarter/i", "0.25"
    text.gsub! "/eighth/i", "0.125"
    text.gsub! "/ounces/i", "oz"
    text.gsub! "/ounce/i", "oz"
    text.gsub! "/grams/i", "g"
    text.gsub! "/gram/i", "g"
    unit = Unit.new text
    unit.convert_to(units).scalar
  end
end
