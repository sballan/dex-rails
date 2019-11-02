class FollowUrlJob < ApplicationJob
  queue_as :low

  def perform(page_url:, counter: 1)
    return if counter < 1
    counter -= 1

    if page_url.is_a? Integer
      page_url = Url.find page_url
    end

    page = create_page_for_url page_url
    return if page.nil?

    link_urls = page.create_urls_for_links
    link_urls.map do | link_url |
      self.class.perform_later(page_url: link_url.id, counter: counter)
    end
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
