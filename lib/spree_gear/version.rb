module SpreeGear
  module_function

  # Returns the version of the currently loaded SpreeGear as a
  # <tt>Gem::Version</tt>.
  def version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 1
    MINOR = 9
    TINY  = 19

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
  end

end
