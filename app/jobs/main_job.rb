class MainJob < ApplicationJob
  queue_as :low

  def perform(num = 0)
    raise "MainJon couldn't run a single job" if num <= 0
    url = Url.create value: 'https://example.com'
    page = url.pages.create
    Crawling::FollowUrlsForPageJob.perform_now(page: page, depth: 1)

    return if num <= 1
    CreatePagesForUrlsJob.perform_now 10_000

    return if num <= 2
    FollowUrlJob.perform_later(
      page_url: Url.create(value: 'https://harrypotter.fandom.com/wiki/Main_Page'),
      counter: 4
    )

    return if num <= 3
    QueueParseWordsForPagesJob.perform_later 600, 700

    return if num <= 4
    Matching::RunFullPageParseJob.perform_later(page.first)
  end
end
