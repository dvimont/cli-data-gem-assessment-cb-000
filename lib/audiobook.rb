class Audiobook
  @@all = Array.new

  def self.mass_initialize(hash_array)
    hash_array.each{ |hash| Audiobook.new(hash) }
  end

  def self.all()
    return @@all
  end

  def self.list_all()
    self.all.each {|audiobook| puts audiobook.to_s }
  end

  attr_accessor :url_librivox, :url_iarchive, :url_text_source

  def initialize(attributes)
    self.add_attributes(attributes)
    if @@all.detect{|a| a.url_librivox == self.url_librivox}
       puts "DUPLICATE URL ENCOUNTERED: " + self.url_librivox
    else
      @@all << self
    # if !@@all.detect{|a| a.url_librivox == self.url_librivox}
    end
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def to_s()
    output_string = :url_librivox.to_s + ": " + self.url_librivox
    return output_string
  end

end
