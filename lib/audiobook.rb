class Audiobook
  @@all = SortedSet.new
  @@works_in_progress = SortedSet.new

  def self.mass_initialize(hash_array)
    hash_array.each{ |hash| Audiobook.new(hash) }
  end

  def self.all()
    return @@all
  end

  def self.works_in_progress
    return @@works_in_progress
  end

  def self.list_all()
    self.all.each {|audiobook| puts audiobook.to_s }
  end

  attr_accessor :id, :url_librivox, :title, :date_released, :http_error
                 #, :url_iarchive, :url_text_source
  attr_reader :language_object, :authors, :readers, :genres
  # may want to ultimately make the following attr_writer only (no public access)
  attr_accessor :language, :authors_hash, :genre_csv_string, :readers_hash


  def initialize(attributes)
    self.add_attributes(attributes)
    if (self.url_librivox == nil || self.url_librivox == "") # only completed audiobooks have URL
      @@works_in_progress.add(self)
    else
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

  def build_category_objects
    if self.language != nil && self.language != ""
      @language_object = Language.create_or_get_existing(self.language)
      @language_object.add_audiobook(self)
    end
    if self.authors_hash != nil && !self.authors_hash.empty?
      @authors = Author.mass_initialize(self.authors_hash)
      @authors.each{|author| author.add_audiobook(self)}
    end
    if self.readers_hash != nil && !self.readers_hash.empty?
      @readers = Reader.mass_initialize(self.readers_hash)
      @readers.each{|reader| reader.add_audiobook(self)}
    end
  end

  def to_s()
    output_string = "\n" +
        :id.to_s + ": " + self.id +
        "\n  " + :url_librivox.to_s + ": " + self.url_librivox +
        "\n  " + :title.to_s + ": " + self.title +
        "\n  " + :authors_hash.to_s + ": " + self.authors_hash.to_s +
#        "\n  " + :readers_hash.to_s + ": " + self.readers_hash.to_s +
#        "\n  " + :language.to_s + ": " + self.language.to_s +
#        "\n  " + :genre_csv_string.to_s + ": " + self.genre_csv_string +
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
