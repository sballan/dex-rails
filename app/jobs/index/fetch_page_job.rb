# frozen_string_literal: true

module Index
  class FetchPageJob < ApplicationJob
    queue_as :downloading

    def perform(page)
      page.fetch_page
    end
  end
end
