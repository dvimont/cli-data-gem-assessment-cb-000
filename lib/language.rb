class Language
  extend Category::ClassMethods
  include Category::InstanceMethods

  @@SUBCATEGORIZABLE = false

  def to_s()
    return self.id
  end
end
