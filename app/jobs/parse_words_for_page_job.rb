class ParseWordsForPageJob < ApplicationJob
  queue_as :default

  def perform(page)
    if page.is_a?(Integer) || page.is_a?(String)
      page = Page.find page
    end

    require 'html2text'
    text = Html2Text.convert(page.document.text)
    words = text.split(/\s/)
    words.each {|word| FindOrCreateWordJob.perform_later word }
  end
end
