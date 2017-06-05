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

  attr_accessor :id, :url_librivox, :title, :language, :date_released,
                :http_error, :author_data, :genre_data, :reader_data
                 #, :url_iarchive, :url_text_source

  def initialize(attributes)
    self.add_attributes(attributes)
    if !(self.url_librivox == nil || self.url_librivox == "") # only completed audiobooks have URL
      @@all.add(self)
    end
  end

  def add_attributes(attributes)
    attributes.each {|key, value|
      if value.is_a?(String) && value.start_with?("http:")
        value = "https" + value[4,value.length]
      end
      self.send(("#{key}="), value)
    }
  end

  def to_s()
    output_string = "\n" +
        :id.to_s + ": " + self.id +
        "\n  " + :url_librivox.to_s + ": " + self.url_librivox +
        "\n  " + :title.to_s + ": " + self.title +
        "\n  " + :author_data.to_s + ": " + self.author_data.to_s +
        "\n  " + :reader_data.to_s + ": " + self.reader_data.to_s +
        "\n  " + :language.to_s + ": " + self.language +
        "\n  " + :genre_data.to_s + ": " + self.genre_data +
        "\n  " + :date_released.to_s + ": " + self.date_released
    if self.http_error != nil
      output_string += "\n  " + :http_error.to_s + ": " + self.http_error
    end
    return output_string
  end

  def <=>(other)
    return self.id <=> other.id
  end
end
