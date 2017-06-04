require 'open-uri'
require 'json'
require 'nokogiri'

class CatalogBuilder

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_API_PARMS = "?fields={id,url_librivox}&format=json"
  DEFAULT_CATALOG_SIZE = 100
  LIMIT_PER_CALL = 50

  def self.build(catalog_size=DEFAULT_CATALOG_SIZE, optional_parms="")
    offset = 0
    records_remaining_to_fetch = catalog_size

    while records_remaining_to_fetch > 0
      call_limit = (records_remaining_to_fetch > LIMIT_PER_CALL) ?
                            LIMIT_PER_CALL : records_remaining_to_fetch
      records_remaining_to_fetch -= call_limit

      puts "** Call to API sent for #{call_limit.to_s} records at offset #{offset.to_s}: " + current_time

      begin
        api_result = open(LIBRIVOX_API_URL + LIBRIVOX_API_PARMS +
            "&offset=" + offset.to_s + "&limit=" + call_limit.to_s + optional_parms,
            :read_timeout=>nil)
      rescue OpenURI::HTTPError => ex
        if ex.to_s.start_with?("404")
          puts "** HTTP 404 response from Librivox API; apparent end of catalog has been reached! **"
        else
          puts "** Error has been returned by OpenURI during call to Librivox API. Error message is as follows:"
        end
        puts ex.to_s
        puts "====="
        break
      end

      offset += call_limit
      puts "** Call to API completed: " + current_time

      json_string = api_result.read
      puts "** Reading into JSON string completed: " + current_time

      returned_hash = JSON.parse(json_string,{symbolize_names: true})
      hash_array = returned_hash.values[0]
      puts "** Conversion of JSON string into Hash completed: " + current_time

      Audiobook.mass_initialize(hash_array)
      puts "** Initialization of Audiobook set completed: " + current_time
      puts "====="
    end

    self.scrape_webpages
  end

  def self.scrape_webpages
    puts "** STARTING scraping of pages for #{Audiobook.all.size.to_s} audiobooks: " +
        current_time


    puts "** COMPLETED scraping of pages for #{Audiobook.all.size.to_s} audiobooks: " +
        current_time
  end

  def self.current_time
    current_time = Time.now.to_s
    current_time = current_time.slice(0,current_time.length - 6)
    return current_time
  end
end
