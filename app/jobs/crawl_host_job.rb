
class CrawlHostJob < ApplicationJob
  queue_as :crawling

  def perform(host)
    if host.is_a? Integer
      host = Host.find host
    end
  end
end