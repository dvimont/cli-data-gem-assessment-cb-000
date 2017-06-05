class Language < Category
  @@SUBCATEGORIZABLE = false
  @@all = SortedSet.new

  def self.create_or_get_existing(id_string)
    new_object = self.all.to_a.bsearch{|category| category.id >= id_string}
    if new_object == nil
      new_object = Language.new(id_string)
    end
    return new_object
  end

  def self.all
    return @@all
  end

  def initialize(id_string)
    super({id: id_string})
  end

  def to_s()
    return self.id
  end
end
