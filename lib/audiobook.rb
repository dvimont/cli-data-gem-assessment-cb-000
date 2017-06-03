class Audiobook
  @@all = SortedSet.new

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
    @@all.add(self)
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def to_s()
    output_string = :url_librivox.to_s + ": " + self.url_librivox
    return output_string
  end

  def <=>(other)
    return self.url_librivox <=> other.url_librivox
  end

end
