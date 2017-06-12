class CliController

  def initialize(catalog_size=CatalogBuilder.default_catalog_size)
    puts "PLEASE WAIT WHILE AUDIOBOOK CATALOG IS INITIALIZED!!"
    puts ""
    CatalogBuilder.build(catalog_size)
  end

  HORIZONTAL_LINE = "\n======================================================\n"
  REINPUT_REQUEST = "Sorry, I didn't recognize your command!\nPlease note the command options above, and try again!!"
  EXIT_COMMANDS = ["exit", "quit", "q", "x", "0"]

  def start
    input = ""
    puts HORIZONTAL_LINE + "Welcome to Librivox Explorer's COMMAND LINE INTERFACE!" + HORIZONTAL_LINE
    invalid_input = false
    until EXIT_COMMANDS.include?(input)
      if invalid_input
        puts REINPUT_REQUEST
      else
        puts  "  ::TOP LEVEL MENU::"
        puts  "  Please select one of the following commands by its number:\n" +
              "    ---------\n" +
              "    1 -- browse by Librivox Genre (#{GenreLibrivox.all.size.to_s})\n" +
              "    2 -- browse by Gutenberg Genre (#{GenreGutenberg.all.size.to_s})\n" +
              "    3 -- browse by Author (#{Author.all.size.to_s})\n" +
              "    4 -- browse by Reader (#{Reader.all.size.to_s})\n" +
              "    ---------\n" +
              "    0 -- exit"
        puts ""
      end

      invalid_input = false
      print ">> "; input = gets.strip

      case input
      when "1"
        browse_by_genre_librivox
      when "2"
        browse_by_genre_gutenberg
      when "3"
        browse_by_author
      when "4"
        browse_by_reader
      else
        if EXIT_COMMANDS.include?(input)
          puts "\nThanks for visiting Librivox Explorer's CLI. Your session is completed!!"
          puts ""
        else
          invalid_input = true
        end
      end
    end
  end

  def browse_by_author
    input = ""
    invalid_input = false
    until EXIT_COMMANDS.include?(input)
      if invalid_input
        puts REINPUT_REQUEST
      else
        puts "  ::BROWSING BY AUTHOR::"
        puts "  Step 1: Please enter a letter [a thru z] to view Artists whose surname begins with it...\n"
             "    ---------\n" +
             "    0 -- exit"
        puts ""
      end

      invalid_input = false
      print ">> "; input = gets.strip

  #    if !("A".."Z").include?(input.upcase)
  #      invalid_input = true
  #      next
  #    end
      self.browse_by_author_subset(input)
    end
  end

  SCROLL_SIZE = 10

  def browse_by_author_subset(surname_prefix)
    #author_list = Author.all_by_name.select {|k,v| k[0].upcase == surname_prefix.upcase}
    author_kv_pairs = Author.all_by_name.key_starts_with(surname_prefix.upcase)
    counter = 0
    author_kv_pairs.each {|kv_pair|
      counter += 1
      puts "   #{counter.to_s}: #{kv_pair[1].to_s}"
    }
    puts "Enter number to list an author's audiobooks; enter to continue scrolling; 0 to exit."
    print "MORE >> "; input = gets.strip
  end
end
