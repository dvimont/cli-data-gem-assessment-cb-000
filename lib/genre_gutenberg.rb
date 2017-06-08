class GenreGutenberg
  extend Category::ClassMethods
  include Category::InstanceMethods

  @@SUBCATEGORIZABLE = true

  def self.mass_initialize(gutenberg_subjects)
    genres_gutenberg = Array.new

    gutenberg_subjects.each { |genre_string|
      genre_string.strip!
      if !genre_string.nil? && !genre_string.empty?
        genres_gutenberg.push(self.create_or_get_existing(genre_string))
      end
    }
    return genres_gutenberg
  end

end
