class MainJob < ApplicationJob
  queue_as :low

  def perform
    CreatePagesForUrlsJob.perform_later 10_000
    FollowUrlJob.perform_later page_url: Url.create(value: 'https://harrypotter.fandom.com/wiki/Main_Page'), counter: 4
    QueueParseWordsForPagesJob.perform_later 600, 700
  end
end
