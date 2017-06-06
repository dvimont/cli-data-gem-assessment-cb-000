class Genre
  extend Category::ClassMethods
  include Category::InstanceMethods

  @@SUBCATEGORIZABLE = false

end
