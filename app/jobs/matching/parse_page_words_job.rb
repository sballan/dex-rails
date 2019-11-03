module Matching
  class ParsePageWordsJob < ActiveJob::Base
    queue_as :low

    def perform(page)
      if page.is_a?(Integer) || page.is_a?(String)
        page = Page.find page
      end

      words = Text::Word.create_words_for_page(page)
      return if words.empty?

      page.docs << words
      page.save!
    end
  end
end
