class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  def perform(urls)
    urls.map do |url_string|
      page = Page.find_or_create_by url_string: url_string
      page.persist_page_content
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
