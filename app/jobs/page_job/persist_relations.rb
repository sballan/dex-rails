module PageJob
  class PersistRelations < ApplicationJob
    queue_as :persisting

    def perform(page_id)
      page = Page.find(page_id)

      unless page.page_content_persisted?
        Rails.logger.info "PageJob::PersistRelations - Skipping, page not persisted #{page.url_string}"
        return
      end

      # Get words on this page
      words_strings = page.extracted_words_map.keys

      words = words_strings.map do |word_string|
        Word.create_or_find_by! value: word_string
      end

      Rails.logger.info "PageJob::PersistRelations - Words persisted for: #{page.url_string}"

      page_words = words.map do |word|
        page_count = page.extracted_words_map[word.value]
        PageWord.create_or_find_by! word: word, page: page, page_count: page_count
      end

      Rails.logger.info "PageJob::PersistRelations - PageWords persisted for: #{page.url_string}"
    end
  end
end