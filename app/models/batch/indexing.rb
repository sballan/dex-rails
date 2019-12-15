# frozen_string_literal: true

class Batch
  class Indexing < Batch
    def perform_now
      start!
      pages.in_batches(of: 10).each_record do |page|
        download_page(page)
        parse_page(page)
        index_page(page)
      end
      stop!
      succeed!
    end

    def perform_later
      start!
      pages.in_batches(of: 100).each_record do |page|
        DownloadJob.perform_later(self, page)
      end
    end

    # @param [::Page] page
    def download_page(page)
      mechanize_page_string = begin
        Rails.logger.debug "Running mechanize_page_string: #{self[:url_string]}"
        mechanize_page = page.create_mechanize_page
        mechanize_page.body.to_s
      end

      Services::Cache.write(
        "#{cache_key}/#{page.cache_key}/download",
        mechanize_page_string,
        expire_time: 1.week
      )
    end

    # @param [::Page] page
    def parse_page(page)
      page_content = begin
        downloaded_page = Services::Cache.read("#{cache_key}/#{page.cache_key}/download")

        mechanize_page = Mechanize::Page.new(
          nil,
          { 'content-type' => 'text/html' },
          downloaded_page,
          nil,
          Mechanize.new
        )

        noko_doc = Nokogiri::HTML.parse(mechanize_page.body)
        noko_doc.xpath('//script').remove
        noko_doc.xpath('//style').remove

        text = Html2Text.convert noko_doc.text
        word_values = text.split /\s/
        downcase_words = word_values.map do |word_value|
          word_value.downcase!
        rescue StandardError => e
          Rails.logger.info "Could not downcase #{word_value}: #{e.message}"
          word_value
        end

        {
          title: mechanize_page.title,
          links: mechanize_page.links.map do |mechanize_link|
            mechanize_link.resolved_uri.to_s
                 rescue StandardError
                   nil
          end.compact,
          extracted_words: downcase_words
        }
      end

      Services::Cache.write(
        "#{cache_key}/#{page.cache_key}/parse",
        page_content,
        expire_time: 1.week
      )

      Services::Cache.delete("#{cache_key}/#{page.cache_key}/download")
    end

    def index_page(page)
      parsed_page = Services::Cache.read("#{cache_key}/#{page.cache_key}/parse")

      page[:word_count] = parsed_page[:extracted_words].size
      page.save!

      extracted_words_map = {}.tap do |map|
        parsed_page[:extracted_words].each do |extracted_word|
          map[extracted_word] ||= 0
          map[extracted_word] += 1
        end
      end

      words_strings = extracted_words_map.keys

      word_objects = Word.fetch_persisted_objects_for(words_strings)

      word_objects.map do |word|
        page_count = extracted_words_map[word[:value]]
        page_word = PageWord.create_or_find_by! page_id: page.id, word_id: word[:id]
        page_word[:page_count] = page_count
        page_word.save!
      end

      parsed_page[:links].uniq.each do |link|
        Page.create_or_find_by!(url_string: link)
      end

      page[:download_success] = Time.now.utc
      page.save!

      Services::Cache.delete("#{cache_key}/#{page.cache_key}/parse")

      Rails.logger.info "Successfully indexed #{page[:url_string]}"
    end
  end
end
