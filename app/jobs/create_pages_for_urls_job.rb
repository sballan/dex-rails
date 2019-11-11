class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  def perform(urls)
    urls.map {|url_string| Page.find_or_create_by url_string: url_string}
    GC.start(full_mark: false, immediate_sweep: false)
  end
end
