# frozen_string_literal: true

module Index
  class IndexPageJob < ApplicationJob
    queue_as :indexing

    def perform(page)
      page.index_page

      page.data && page.data['links'].each do |link|
        Index::Page.create_or_find_by!(url_string: link)
      end
    end
  end
end
