class IndexingBatch < ApplicationRecord
  has_and_belongs_to_many :pages

  def perform_now
    start!
    pages.in_batches(of: 1).each_record do |page|
      download_page(page)
      parse_page(page)
      index_page(page)
    end
    stop!
    succeed!
  end

  def perform_later
    start!
    pages.in_batches(of: 10).each_record do |page|
      DownloadJob.perform_later(self, page)
    end
  end

  # @param [::Page] page
  def download_page(page)
    mechanize_page_string = begin
      Rails.logger.debug "Running mechanize_page_string: #{self[:url_string]}"
      mechanize_page = page.create_mechanize_page
      mechanize_page.body.to_s
    end

    Services::Cache.write(
      "#{cache_key}/#{page.cache_key}/download",
      mechanize_page_string,
      expire_time: 1.hour
    )
  end

  # @param [::Page] page
  def parse_page(page)
    page_content = begin
      downloaded_page = Services::Cache.read("#{cache_key}/#{page.cache_key}/download")

      mechanize_page = Mechanize::Page.new(
        nil,
        {'content-type'=>'text/html'},
        downloaded_page,
        nil,
        Mechanize.new
      )

      noko_doc = Nokogiri::HTML.parse(mechanize_page.body)
      noko_doc.xpath('//script').remove
      noko_doc.xpath('//style').remove

      text = Html2Text.convert noko_doc.text
      word_values = text.split /\s/
      downcase_words = word_values.map do |word_value|
        word_value.downcase!
      rescue StandardError => e
        Rails.logger.info "Could not downcase #{word_value}: #{e.message}"
        word_value
      end


      {
        title: mechanize_page.title,
        links: mechanize_page.links.map do |mechanize_link|
          mechanize_link.resolved_uri.to_s
               rescue StandardError
                 nil
        end.compact,
        extracted_words: downcase_words
      }
    end

    Services::Cache.write(
      "#{cache_key}/#{page.cache_key}/parse",
      page_content,
      expire_time: 1.hour
    )
  end

  def index_page(page)
    parsed_page = Services::Cache.read("#{cache_key}/#{page.cache_key}/parse")

    extracted_words_map = {}.tap do |map|
      parsed_page[:extracted_words].each do |extracted_word|
        map[extracted_word] ||= 0
        map[extracted_word] += 1
      end
    end

    words_strings = extracted_words_map.keys

    word_objects = Word.fetch_persisted_objects_for(words_strings)

    word_objects.map do |word|
      page_count = extracted_words_map[word[:value]]
      page_word = PageWord.create_or_find_by! page_id: page.id, word_id: word[:id]
      page_word[:page_count] = page_count
      page_word.save!
    end

    page[:download_success] = Time.now.utc
    page.save!

    Rails.logger.info "Successfully indexed #{page[:url_string]}"
  end

  def start!
    if currently_running?
      raise "Already running this batch"
    end

    current_time = Time.now.utc

    self[:started_at] = current_time
    self[:stopped_at] = nil
    self[:failed_at] = nil
    self[:successful_at] = nil

    Rails.logger.info "Starting IndexingBatch (#{id})" && save!
  end

  def stop!
    self[:stopped_at] = Time.now.utc
    Rails.logger.info "Stopping IndexingBatch (#{id})" && save!
  end

  def fail!
    self[:failed_at] = Time.now.utc
    Rails.logger.info "Failed IndexingBatch (#{id})" && save!
  end

  def succeed!
    self[:successful_at] = Time.now.utc
    Rails.logger.info "Successful IndexingBatch (#{id})" && save!
  end

  def currently_running?
    reload
    return false if self[:started_at].blank?

    self[:started_at] > [
      self[:stopped_at].to_i,
      self[:failed_at].to_i,
      self[:successful_at].to_i
    ].max
  end



  # EVENT_TIMES = [
  #   :created_at,
  #   :updated_at,
  #   :started_at,
  #   :stopped_at,
  #   :failed_at,
  #   :successful_at
  # ]


  # def event_times
  #   Rails.cache.fetch("#{cache_key_with_version}/event_times") do
  #     EVENT_TIMES.map { |event_time| self[event_time] }
  #   end
  # end
end
