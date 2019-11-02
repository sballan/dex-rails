class FollowUrlJob < ApplicationJob
  queue_as :default

  def perform(url_id: url_id, counter: 1)
    return if counter < 1

    counter -= 1
    page_url = url = Url.find url_id

    page = Page.create(
      url: page_url,
      body: url.mechanize_page.body,
      title: url.mechanize_page.title,
      links: url.mechanize_page.links.map(&:resolved_uri )
    )

    link_urls = page.create_urls_for_links

    link_urls.map do | url |
      create_page_for_url(url)
      perform(url_id: url.id, counter: counter)
    end

  end

  def create_page_for_url(url)
    Page.create(
      url: url,
      body: url.mechanize_page.body,
      title: url.mechanize_page.title,
      links: url.mechanize_page.links.map(&:resolved_uri )
    )
  end
end
