class Language < Category
  extend CategoryModule::ClassMethods

  @@SUBCATEGORIZABLE = false

  def initialize(id_string)
    super({id: id_string})
  end

  def to_s()
    return self.id
  end
end
