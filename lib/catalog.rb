require 'open-uri'
require 'json'

class Catalog

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_API_PARMS = "?fields={url_librivox,url_text_source}&format=json&limit="
  LIBRIVOX_DEFAULT_CATALOG_SIZE = "20"

  def initialize(catalog_size=LIBRIVOX_DEFAULT_CATALOG_SIZE.to_i)
    json_string = open(
        LIBRIVOX_API_URL + LIBRIVOX_API_PARMS + catalog_size.to_s).read
    hash_array = JSON.parse(json_string,{symbolize_names: true}).values[0]
    Audiobook.mass_initialize(hash_array)
  end

  def list_all()
    Audiobook.all.each {|audiobook| puts audiobook.to_s }
  end
end
