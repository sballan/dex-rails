class CrawlAllHostsJob < ApplicationJob
  queue_as :retry_crawling

  def perform(num = 100)
    GC.start(full_mark: true, immediate_sweep: true)
    Host.all.to_a.shuffle[0..num].each do |host|
      host.crawl if host.found?
    end
  end
end
