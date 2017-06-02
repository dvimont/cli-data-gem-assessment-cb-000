class Audiobook
  @@all = Array.new

  attr_accessor :url_librivox

  def initialize(url_librivox)
    add_attributes(url_librivox)
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

end
