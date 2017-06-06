class Language < Category
  @@SUBCATEGORIZABLE = false
  @@all = HashWithBsearch.new     # SortedSet.new

  def self.create_or_get_existing(id_string)
    retrieved_object = self.all[id_string]
                      # self.all.to_a.bsearch{|category| category.id >= id_string}
    if retrieved_object == nil
      retrieved_object = Language.new(id_string)
    end
    return retrieved_object
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
