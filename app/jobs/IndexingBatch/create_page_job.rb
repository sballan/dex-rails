# frozen_string_literal: true

class IndexingBatch
  class CreatePageJob < ApplicationJob
    queue_as :create_pages

    def perform(url_string)
      Page.create_or_find_by!(url_string: url_string)
    end
  end
end
