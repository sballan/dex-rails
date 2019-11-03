module Matching
  class RunFullQueryJob < ActiveJob::Base
    queue_as :critical

    def perform(query)
      words = parse_words(query)
    end

    def parse_words(query)
      words = query.split(/\s/)
      words.map!{|word| Text::Word.find_or_create_by(value: word)}

      matches = words.map do |word|
        word.pages.map do |page|
          Match.create doc: word, query: query, page: page
        end
      end

    end
  end
end