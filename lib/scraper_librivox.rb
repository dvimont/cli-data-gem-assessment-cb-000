require 'json'
require 'nokogiri'

class ScraperLibrivox
  LOCAL_WEBPAGE_URI_PREFIX = "./fixtures/web_pages/"

  class << self
    def get_audiobook_attributes_hash(url_librivox, special_processing=:none)
      attributes = Hash.new
      begin
        if url_librivox.start_with?("http:")
          url_librivox = "https" + url_librivox[4,url_librivox.length]
        end
        if special_processing != :local_uri_calls
          retrieve_and_persist_http_response(url_librivox)
        end

        page_content = Nokogiri::HTML(open(get_local_uri(url_librivox), :read_timeout=>nil))
        book_page_section = page_content.css("div.main-content div.page.book-page")
        if book_page_section.nil? || book_page_section.size == 0
          return attributes
        end
        book_page_sidebar_section = page_content.css(
                "div.main-content div.sidebar.book-page div.book-page-sidebar")

        # SCRAPE: title, genre, and url_cover_art
        title_genre_section = book_page_section.css("div.content-wrap")
        title_element = title_genre_section.css("h1")[0]
        if title_element
          attributes[:title] = title_genre_section.css("h1")[0].text
        else
          puts "  -- no title found for audiobook at url: " + url_librivox
          attributes[:title] = "NO TITLE: " + url_librivox
        end

        genre_elements = title_genre_section.css("p.book-page-genre")
        genre_elements.each{ |element|
          if element.css("span").text == "Genre(s):"
            attributes[:genres_csv_string] = element.text[10, element.text.length]
            break
          end
        }

        cover_art_img_element = title_genre_section.css("div.book-page-book-cover img")
        if cover_art_img_element
          attributes[:url_cover_art] = cover_art_img_element.attribute("src").value
        end

        # SCRAPE: date-released from sidebar section
        product_details = book_page_sidebar_section.css("dl.product-details *")
        previous_text = ""
        product_details.each {|element|
          if previous_text == "Catalog date:"
            attributes[:date_released] = element.text
            break
          end
          previous_text = element.text
        }

        # SCRAPE: url_text from sidebar section
        links = book_page_sidebar_section.css("p a")
        links.each {|element|
          if element.text.upcase[/.*ONLINE TEXT.*/]
            url_text = element.attribute("href").value
            attributes[:url_text] = url_text
            if url_text[/gutenberg.org\/etext\/\d+$/]
              attributes[:gutenberg_id] = url_text[/\d+$/]
            end
          elsif element.text.upcase[/.*INTERNET ARCHIVE PAGE.*/]
            attributes[:url_iarchive] = element.attribute("href").value
          end
        }

        readers_hash = extract_contributors_hash(book_page_section, "reader")
        if !readers_hash.empty?
          attributes[:readers_hash] = readers_hash
        end

        authors_hash = extract_contributors_hash(book_page_section, "author")
        if !authors_hash.empty?
          attributes[:authors_hash] = authors_hash
        end

      rescue OpenURI::HTTPError => ex
        attributes[:http_error] = ex.to_s
      end

      return attributes
    end

    # NOTE: author & reader (contributor) "a" elements contain
    #   (1) href attribute with url that ends with author-id or reader-id, and
    #   (2) value containing author's or reader's displayable name and
    #       OPTIONAL (birth-death) designation.
    #   The hash returned by this method contains entries like:
    #     {"110" => "Cynthia Lyons (1946-2011)"}
    def extract_contributors_hash(book_page_section, contributor_type)
      contributors_hash = Hash.new
      # Author's and Reader's "a" elements are placed in varying locations, but their
      #   structure is always identifiable by the following wildcard css search.
      contributor_elements = book_page_section.css('a[href*="/' + contributor_type + '/"]')
      if contributor_elements
        contributor_elements.each{ |contributor_element|
          contributor_id = contributor_element.attribute("href").value[/\d+$/]
          contributor_text = contributor_element.text
          if contributor_id && contributor_text
            contributors_hash[contributor_id] = contributor_text
          end
        }
      end
      return contributors_hash
    end

    def retrieve_and_persist_http_response(url)
      # if webpage already stored locally, do not do remote call & persist
      begin
        Nokogiri::HTML(open(get_local_uri(url), :read_timeout=>nil))
      # rescue OpenURI::HTTPError => ex
      rescue Errno::ENOENT
        # if not found locally carry on with remote call & persist
      else
        return
      end
      open(get_local_uri(url), "wb") { |file|
        open(url, {:read_timeout=>nil, :redirect=>false}) { |uri| file.write(uri.read) }
      }
    end

    def get_local_uri(url)
      url_prefix_length = url[/https?:\/\//].length
      substring_length = url.length - url_prefix_length
      substring_length -= 1 if url.end_with?("/")
      return LOCAL_WEBPAGE_URI_PREFIX + url[url_prefix_length,substring_length]
    end
  end
end
