# frozen_string_literal: true

class Batch
  class Downloading < Batch
    def perform_now
      start!

      Mechanize.start do |agent|
        agent.robots = true
        pages.each do |page|
          download_page(page, agent)
        end
      end

      stop!
      succeed!
    rescue StandardError => e
      fail!
      raise e
    end

    def download_page(page, agent)
      Rails.logger.debug "Downloading page #{self[:url_string]}"
      mechanize_page_string = page.fetch_with_agent(agent)

      Services::Cache.write(
        "#{cache_key}/#{page.cache_key}/download",
        mechanize_page_string,
        expire_time: 1.week
      )
    end
  end
end
