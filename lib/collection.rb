require 'open-uri'
require 'json'
require_relative 'audiobook'

class Collection

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_CATALOG_SIZE = "20"
  LIBRIVOX_API_CALL_FOR_AUDIOBOOK_URLS = LIBRIVOX_API_URL +
                "?fields={url_librivox}&format=json&limit=#{LIBRIVOX_CATALOG_SIZE}"

  def initialize()
    json_string = open(LIBRIVOX_API_CALL_FOR_AUDIOBOOK_URLS).read
    url_librivox_hash_array = JSON.parse(json_string,{symbolize_names: true}).values[0]
    Audiobook.mass_initialize(url_librivox_hash_array)
  end

end

Collection.new
