module Matching
  class RunFullPageParseJob < ActiveJob::Base
    queue_as :critical

    def perform(page)
      if page.is_a?(Integer) || page.is_a?(String)
        page = Page.find page
      end

      words = parse(page)
      page.words = words
      page.save

      page.links.each do |link|
        CreatePageForUrlJob.perform_later(
          Url.find_or_create_by(
            value: link
          ).id
        )
      end
    end

    def parse(page)
      words = page.document.text.split(/\s/)
      words.map{|word| Doc::Word.find_or_create_by(value: word)}
    end
  end
end
