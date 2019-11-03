class CreatePageForUrlJob < ApplicationJob
  queue_as :default

  def perform(url)
    if url.is_a? Integer
      url = Url.find url
    end
    page = create_page_for_url url
    Matching::RunFullPageParseJob.perform_later page.id
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
