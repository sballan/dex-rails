class CreateWordsForValuesJob < ApplicationJob
  queue_as :persisting

  def perform(word_strings)
    @pg_words_id_to_value = Redis::HashKey.new 'pg_words_id_to_value', marshal: true, expireat: ->{ Time.now + 1.hour }
    @pg_words_value_to_id = Redis::HashKey.new 'pg_words_value_to_id', marshal: true, expireat: ->{ Time.now + 1.hour }

    words = word_strings.map {|word_string| Word.find_or_create_by value: word_string}
    words.each do |word|
      @pg_words_id_to_value[word.id] = word.value unless @pg_words_id_to_value.has_key? word.id
      @pg_words_value_to_id[word.value] = word.id unless @pg_words_value_to_id.has_key? word.value
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
