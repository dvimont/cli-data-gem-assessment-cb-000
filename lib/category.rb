class Category # abstract class

#  class << self  # establishes a block for defining class methods and fields
#    attr_reader :all
#    @all = SortedSet.new
#  end

  attr_accessor :id
  attr_reader :audiobooks, :audiobooks_by_title, :audiobooks_by_date

  def initialize(attributes)
    self.add_attributes(attributes)
    self.class.all[self.id] = self

    @audiobooks = SortedSet.new # default (id) order
    @audiobooks_by_title = HashWithBsearch.new # {|a,b| a.title <=> b.title}
    @audiobooks_by_date = SortedSet.new # {|a,b| b.date_released <=> a.date_released}
  end

  def add_attributes(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def add_audiobook(audiobook)
    if !self.audiobooks.include?(audiobook)
      self.audiobooks.add(audiobook)
      title_key = audiobook.title
      if title_key.upcase.start_with?("THE ")
        title_key = title_key[4,title_key.length]
      end
      self.audiobooks_by_title[title_key] = audiobook
      self.audiobooks_by_date.add(audiobook)
    end
  end

  def <=>(other)
    return self.id <=> other.id
  end
end
