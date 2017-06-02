class Collection

  LIBRIVOX_API_URL = "https://librivox.org/api/feed/audiobooks/"
  LIBRIVOX_CATALOG_SIZE = "2000"
  LIBRIVOX_API_CALL_FOR_AUDIOBOOK_URLS = LIBRIVOX_API_URL +
                "?fields={url_librivox}&format=json&limit=#{LIBRIVOX_CATALOG_SIZE}"


end
