class Author
  extend Category::ClassMethods
  include Category::InstanceMethods
  
  @@SUBCATEGORIZABLE = true

end
