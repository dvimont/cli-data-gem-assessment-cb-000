require 'open-uri'
require 'json'

class CatalogBuilder

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_API_PARMS = "?fields={url_librivox}&format=json&limit="
  LIBRIVOX_DEFAULT_CATALOG_SIZE = "20"

  def self.build(catalog_size=LIBRIVOX_DEFAULT_CATALOG_SIZE.to_i,
        optional_parms="")
    puts "** Call to API sent for #{catalog_size.to_s} records: " + Time.now.to_s
    api_result = open(LIBRIVOX_API_URL + LIBRIVOX_API_PARMS +
        catalog_size.to_s + optional_parms,
        :read_timeout=>nil)
    puts "** Call to API completed: " + Time.now.to_s

    json_string = api_result.read
    puts "** Reading into JSON string completed: " + Time.now.to_s

    hash_array = JSON.parse(json_string,{symbolize_names: true}).values[0]
    # NOTE: Librivox API may return records with blank url
    hash_array.delete_if{|hash| hash.values[0] == ""}
    puts "** Conversion of JSON string into Hash completed: " + Time.now.to_s

    Audiobook.mass_initialize(hash_array)
    puts "** Initialization of Audiobook collection completed: " + Time.now.to_s
  end

end
