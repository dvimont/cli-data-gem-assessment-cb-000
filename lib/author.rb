class Author
  extend Category::ClassMethods
  include Category::InstanceMethods

  @@SUBCATEGORIZABLE = true
  @@all_by_name = HashWithBsearch.new

  def self.all_by_name
    return @@all_by_name.values
  end

  def self.mass_initialize(hash)
    authors = Array.new
    # NOTE: authors hash can look like this:
    #  {"431"=>"Alexandre DUMAS (1802 - 1870)", "221"=>" UNKNOWN ( - )"}
    hash.each{ |id, author_data_string|
      attributes = Hash.new
      name_date_pair = author_data_string.split("(")
      if name_date_pair[0] != nil
        name_date_pair[0].strip!
        name_components = name_date_pair[0].strip.split
        if name_components != nil && name_components.size > 0
          attributes[:last_name] = name_components.pop
          if name_components.size > 0
            attributes[:first_name] = name_components.join(" ")
          end
        end
      end
      if name_date_pair[1] != nil
        years = name_date_pair[1].strip.delete!(")").split(" - ")
        if years[0] != nil && !years[0].empty? && years[0].length >= 4
          attributes[:birth_year] = years[0]
        end
        if years[1] != nil && !years[1].empty? && years[1].length >= 4
          attributes[:death_year] = years[1]
        end
      end
      authors.push(Author.create_or_get_existing(id, attributes))
    }
    return authors
  end

  attr_accessor :last_name, :first_name, :birth_year, :death_year

  def add_self_to_class_collections()
    super
    if self.last_name.to_s == "VERSION" || self.last_name.to_s == "VULGATA"
      name_key = self.first_name.to_s + " " + self.last_name.to_s
    else
      name_key = self.last_name.to_s +
                  ("_" * (30 - self.last_name.length)) + self.first_name.to_s
    end
    @@all_by_name[name_key.upcase] = self
  end

  def to_s()
    returned_string = ""
    returned_string += self.first_name + " "  if !self.first_name.nil?
    returned_string += self.last_name
    if (!self.birth_year.nil? && !self.birth_year.empty?) ||
          (!self.death_year.nil? && !self.death_year.empty?)
      returned_string += " (#{self.birth_year}-#{self.death_year})"
    end
    return returned_string
  end
end
