class CreatePagesForUrlsJob < ApplicationJob
  queue_as :default

  def perform(num=10)
    urls = Url.includes(:pages).where(pages: { url_id: nil }).limit(num)
    pages = urls.map do |url|
      # create_page_for_url url
      CreatePageForUrlJob.perform_later url
    end

    Rails.logger.debug "Successfully created #{pages.count} pages"
  end

  def create_page_for_url(url)
    mechanize_page = url.mechanize_page
    return if mechanize_page.nil?

    if (page = Page.find_by(url: url))
      return page if page.created_at > 1.week.ago
    end

    Page.create(
      url: url,
      body: mechanize_page.body,
      title: mechanize_page.title,
      links: mechanize_page.links.map do |mechanize_link|
        mechanize_link.resolved_uri rescue nil
      end.compact
    )
  end
end
