class CreatePagesForUrlsJob < ApplicationJob
  queue_as :default

  def perform(num=50)
    urls = Url.includes(:pages).where(pages: { url_id: nil }).limit(num)
    pages = urls.map do |url|
      CreatePageForUrlJob.perform_later url
    end

    Rails.logger.debug "Successfully created #{pages.count} pages"
  end
end
