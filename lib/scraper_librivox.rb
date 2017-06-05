require 'open-uri'
require 'json'
require 'nokogiri'

class ScraperLibrivox

  class << self
    def get_audiobook_attributes_hash(url_librivox)
      attributes = Hash.new
      begin
        page_content = Nokogiri::HTML(open(url_librivox, :read_timeout=>nil))
        # title, author, genre
        title_author_genre_section =
              page_content.css("div.main-content div.page div.content-wrap")
        attributes[:title] = title_author_genre_section.css("h1")[0].text

        author_elements = title_author_genre_section.css("p.book-page-author a")
        authors_hash = Hash.new
        author_elements.each {|element|
          # NOTE: author data consists of (1) url ending w/ author-id (2) string
          #   containing author's displayable name and (birth-death) designation.
          authors_hash[element.attribute("href").value[/\d+$/]] = element.text
        }
        if !authors_hash.empty?
          attributes[:author_data] = authors_hash
        end

        genre_elements = title_author_genre_section.css("p.book-page-genre")
        genre_elements.each{ |element|
          if element.css("span").text == "Genre(s):"
            attributes[:genre_data] = element.text[10, element.text.length]
            break
          end
        }

        # date-released from sidebar section
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

        # readers
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
              readers_hash[reader_element.attribute("href").value[/\d+$/]] = reader_element.text
            end
          }
          if !readers_hash.empty?
            attributes[:reader_data] = readers_hash
          end
        end


      rescue OpenURI::HTTPError => ex
        attributes[:http_error] = ex.to_s
      end

      return attributes
    end
  end
end
