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
        if special_processing == :save_http_responses
          retrieve_and_persist_http_response(url_librivox)
        end
        if special_processing == :local_uri_calls
          uri = get_local_uri(url_librivox)
        else
          uri = url_librivox
        end

        page_content = Nokogiri::HTML(open(uri, :read_timeout=>nil))

        # SCRAPE: title, author, & genre
        title_author_genre_section =
              page_content.css("div.main-content div.page div.content-wrap")
        attributes[:title] = title_author_genre_section.css("h1")[0].text

        author_elements = title_author_genre_section.css("p.book-page-author a")
        authors_hash = Hash.new
        author_elements.each {|element|
          # NOTE: author data consists of (1) url ending w/ author-id (2) string
          #   containing author's displayable name and (birth-death) designation.
          # The following statement builds a hash entry like:
          #   {"91" => "Charles DICKENS (1812 - 1870)"}
          authors_hash[element.attribute("href").value[/\d+$/]] = element.text
        }
        # NOTE: authors_hash added to attributes hash below, after possible
        #   multiple authors are scraped from the table section of the page.

        genre_elements = title_author_genre_section.css("p.book-page-genre")
        genre_elements.each{ |element|
          if element.css("span").text == "Genre(s):"
            attributes[:genres_csv_string] = element.text[10, element.text.length]
            break
          end
        }

        # SCRAPE: date-released from sidebar section
        product_details = page_content.css(
            "div.main-content div.sidebar.book-page div.book-page-sidebar dl.product-details *")
        previous_text = ""
        product_details.each {|element|
          if previous_text == "Catalog date:"
            attributes[:date_released] = element.text
            break
          end
          previous_text = element.text
        }

        # SCRAPE: url_text from sidebar section
        links = page_content.css(
            "div.main-content div.sidebar.book-page div.book-page-sidebar p a")
        links.each {|element|
          if element.text.upcase[/.*ONLINE TEXT.*/]
            url_text = element.attribute("href").value
            attributes[:url_text] = url_text
            if url_text[/gutenberg.org\/etext\/\d+$/]
              attributes[:gutenberg_id] = url_text[/\d+$/]
            end
            break
          end
        }

        # SCRAPE: readers
          # examine "thead" section to see in which "column" readers are displayed
        chapter_download_table = page_content.css(
                  "div.main-content div.page.book-page table.chapter-download")
        reader_index = nil
        headers = chapter_download_table.css("thead tr th")
        headers.each_with_index {|element, i|
          if element.text == "Reader"
            reader_index = i
            break
          end
        }
        if reader_index != nil
          rows = chapter_download_table.css("tbody tr")
          readers_hash = Hash.new
          rows.each{|tr_element|
            reader_element = tr_element.css("a")[reader_index]
            if reader_element != nil
              # NOTE: reader data consists of (1) url ending w/ reader-id (2) string
              #   containing reader's displayable name and OPTIONAL (birth-death) designation.
              # The following statement builds a hash entry like:
              #     {"110" => "Cynthia Lyons (1946-2011)"}
              readers_hash[reader_element.attribute("href").value[/\d+$/]] = reader_element.text
            end
          }
          if !readers_hash.empty?
            attributes[:readers_hash] = readers_hash
          end
        end
        # SCRAPE: possible multiple authors
          # examine "thead" section to see in which "column" authors are displayed
        author_index = nil
        headers.each_with_index {|element, i|
          if element.text == "Author"
            author_index = i
            break
          end
        }
        if author_index != nil
          rows = chapter_download_table.css("tbody tr")
          rows.each{|tr_element|
            author_element = tr_element.css("a")[author_index]
            if author_element != nil
              # NOTE: author data consists of (1) url ending w/ author-id (2) string
              #   containing author's displayable name and OPTIONAL (birth-death) designation.
              # The following statement builds a hash entry like:
              #     {"91" => "Charles DICKENS (1812 - 1870)"}
              authors_hash[author_element.attribute("href").value[/\d+$/]] = author_element.text
            end
          }
        end
        if !authors_hash.empty?
          attributes[:authors_hash] = authors_hash
        end

      rescue OpenURI::HTTPError => ex
        attributes[:http_error] = ex.to_s
      end

      return attributes
    end

    def retrieve_and_persist_http_response(url)
      open(get_local_uri(url), "wb") { |file|
        open(url, :read_timeout=>nil) { |uri| file.write(uri.read) }
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
