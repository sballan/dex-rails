# frozen_string_literal: true

class CrawlAllHostsJob < ApplicationJob
  queue_as :retry_crawling

  def perform
    GC.start(full_mark: true, immediate_sweep: true)
    Host.all.to_a.sample(101).each do |host|
      host.crawl if host.found?
    end
  end
end
