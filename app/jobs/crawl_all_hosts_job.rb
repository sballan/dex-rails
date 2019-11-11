class CrawlAllHostsJob < ApplicationJob
  queue_as :retry_crawling

  def perform
    GC.start(full_mark: true, immediate_sweep: true)
    Host.all.to_a.shuffle[0..20].each do |host|
      host.crawl if host.found?
    end
  end
end
