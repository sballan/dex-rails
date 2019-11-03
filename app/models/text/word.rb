module Text
  class Word < Doc
    def self.create_words_for_page(page)
      if page.is_a? Integer
        page = Page.find page
      end

      return [] if page.mechanize_page.nil?

      words = page.noko_doc.text.split(/\s/).reject(&:empty?)
      words.map do |word|
        self.find_or_create_by(value: word)
      end
    end
  end
end
