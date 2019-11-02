class FindOrCreateWordJob < ApplicationJob
  queue_as :critical

  def perform(word)
    Doc::Word.find_or_create_by(value: word)
  end
end
