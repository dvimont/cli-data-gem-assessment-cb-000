class Audiobook
  @@all = Array.new

  def self.mass_initialize(url_librivox_hash_array)
    url_librivox_hash_array.each{ |url_librivox| Audiobook.new(url_librivox) }
  end

  def self.all()
    return @@all
  end

  attr_accessor :url_librivox

  def initialize(url_librivox)
    self.add_attributes(url_librivox)
    @@all << self
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

end
