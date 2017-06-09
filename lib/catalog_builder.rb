require 'open-uri'
require 'json'
require 'nokogiri'

class CatalogBuilder

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_API_PARMS = "?fields={id,url_librivox,language}&format=json"
  DEFAULT_CATALOG_SIZE = 100
  LIMIT_PER_CALL = 50
  LOCAL_API_RESPONSE_URI_PREFIX = "./fixtures/api_responses/"
  @@special_processing_parm = :none

  def self.build(catalog_size=DEFAULT_CATALOG_SIZE, special_processing=:none, optional_parms="")
    @@special_processing = special_processing
    offset = 0
    records_remaining_to_fetch = catalog_size

    while records_remaining_to_fetch > 0
      call_limit = (records_remaining_to_fetch > LIMIT_PER_CALL) ?
                            LIMIT_PER_CALL : records_remaining_to_fetch
      records_remaining_to_fetch -= call_limit

      puts "** Called API for #{call_limit.to_s} records at offset #{offset.to_s}: " + current_time

      begin
        api_parms = LIBRIVOX_API_PARMS +
            "&offset=" + offset.to_s + "&limit=" + call_limit.to_s + optional_parms
        if @@special_processing == :save_http_responses
          open(get_local_uri(api_parms), "wb") { |file|
            open(LIBRIVOX_API_URL + api_parms, :read_timeout=>nil) { |uri|
               file.write(uri.read)
            }
          }
        end
        if @@special_processing == :local_uri_calls
          uri = get_local_uri(api_parms)
        else
          uri = LIBRIVOX_API_URL + api_parms
        end
        api_result = open(uri, :read_timeout=>nil)
      rescue OpenURI::HTTPError => ex
        if ex.to_s.start_with?("404")
          puts "** HTTP 404 response from Librivox API; apparent end of catalog has been reached! **"
        else
          puts "** Error returned by OpenURI during call to Librivox API. Error message is as follows:"
        end
        puts ex.to_s
        puts "====="
        break
      end
      offset += call_limit
      puts "** Call to API completed: " + current_time

      json_string = api_result.read
      returned_hash = JSON.parse(json_string,{symbolize_names: true})
      hash_array = returned_hash.values[0]
      Audiobook.mass_initialize(hash_array)
      puts "** Initialization of Audiobook set completed: " + current_time
      puts "====="
    end

    self.scrape_webpages
    self.build_category_objects
    self.build_solo_group_hashes # must come after Reader category objects instantiated
  end

  def self.scrape_webpages
    puts "** STARTING scraping of Librivox pages for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    Audiobook.all.each{ |audiobook|
      audiobook.add_attributes(
        ScraperLibrivox.get_audiobook_attributes_hash(audiobook.url_librivox, @@special_processing))
    }
    puts "** COMPLETED scraping of Librivox pages for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    puts "====="

    puts "** STARTING scraping of Gutenberg xml docs for #{Audiobook.all_by_gutenberg_id.size.to_s} audiobooks: " + current_time
    ScraperGutenberg.process_gutenberg_genres
    puts "** COMPLETED scraping of Gutenberg xml docs for #{Audiobook.all_by_gutenberg_id.size.to_s} audiobooks: " + current_time
    puts "====="

  end

  def self.build_category_objects
    puts "** STARTING building of Category objects for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    Audiobook.all.each{ |audiobook|
      audiobook.build_category_objects
    }
    puts "** COMPLETED building of Category objects for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    puts "====="
  end

  def self.build_solo_group_hashes
    puts "** STARTING building of Solo and Group hashes for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    Audiobook.all.each{ |audiobook|
      audiobook.build_solo_group_hashes
    }
    puts "** COMPLETED building of Solo and Group hashes for #{Audiobook.all.size.to_s} audiobooks: " + current_time
    puts "====="
  end

  def self.current_time
    current_time = Time.now.to_s
    current_time = current_time.slice(0,current_time.length - 6)
    return current_time
  end

  def self.get_local_uri(api_parms)
    return LOCAL_API_RESPONSE_URI_PREFIX + api_parms
  end

end
