class FollowUrlJob < ApplicationJob
  queue_as :default

  def perform(page_url:, counter: 1)
    return if counter < 1
    counter -= 1

    if page_url.is_a? Integer
      page_url = Url.find page_url
    end


    unless (page = Page.find_by(url: page_url))
      page = create_page_for_url page_url
    end

    link_urls = page.create_urls_for_links

    link_urls.map do | link_url |
      self.class.perform_later(page_url: link_url.id, counter: counter)
    end

    link_urls.map do | url|
      create_page_for_url(url)
    end
  end

  def create_page_for_url(url)
    mechanize_page = url.mechanize_page

    Page.create(
      url: url,
      body: mechanize_page.body,
      title: mechanize_page.title,
      links: mechanize_page.links.map(&:resolved_uri)
    )
  end
end
