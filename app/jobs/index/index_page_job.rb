# frozen_string_literal: true

module Index
  class IndexPageJob < ApplicationJob
    queue_as :indexing

    def perform(page)
      page.index_page
    end
  end
end
