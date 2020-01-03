# frozen_string_literal: true

module Index
  class IndexPageJob < ApplicationJob
    queue_as :indexing

    def perform(page)
      page.index_page

      page.data && page.data['links'].each do |link|
        Index.page_id_cache(link)
      end
    end
  end
end
