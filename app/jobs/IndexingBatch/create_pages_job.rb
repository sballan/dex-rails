# frozen_string_literal: true

class IndexingBatch
  class CreatePagesJob < ApplicationJob
    queue_as :create_pages

    def perform(url_strings)
      url_strings.each do |url_string|
        Page.create_or_find_by!(url_string: url_string)
      end
    end
  end
end
