class Audiobook
  @@all = Array.new

  def self.mass_initialize(hash_array)
    hash_array.each{ |hash| Audiobook.new(hash) }
  end

  def self.all()
    return @@all
  end

  attr_accessor :url_librivox, :url_iarchive, :url_text_source

  def initialize(attributes)
    self.add_attributes(attributes)
    @@all << self
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def to_s()
    output_string = :url_librivox.to_s + ": " + self.url_librivox
    if self.url_text_source != nil
      output_string += "\n -- " + :url_text_source.to_s + ": " + self.url_text_source
    end
    return output_string
  end

end
