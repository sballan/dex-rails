# frozen_string_literal: true

# IndexingBatch.create.tap {|i| i.pages << Page.limit(1000).order("RANDOM()") }.perform_later

class IndexingBatch < ApplicationRecord
  has_and_belongs_to_many :pages

  def perform_now
    start!
    pages.in_batches(of: 100).each_record do |page|
      download_page(page)
      parse_page(page)
      index_page(page)
    end
    stop!
    succeed!
  end

  def perform_later
    start!
    pages.in_batches(of: 50).each_record do |page|
      DownloadJob.perform_later(self, page)
    end
  end

  # @param [::Page] page
  def download_page(page, force = false)
    if !force && page.download_success && page.download_success > 1.day.ago
      raise Page::DownloadTooRecent, "Already successfully downloaded today: #{page.url_string}"
    end

    mechanize_page_string = begin
      Rails.logger.debug "Running mechanize_page_string: #{self[:url_string]}"
      mechanize_page = page.create_mechanize_page
      mechanize_page.body.to_s
    end

    raise 'Mechanize page has no content' if mechanize_page_string.blank?

    Services::Cache.write(
      "#{cache_key}/#{page.cache_key}/download",
      mechanize_page_string,
      expire_time: 1.week
    )
  end

  # @param [::Page] page
  def parse_page(page)
    page_content = begin

      page_text = nil

      Services::Cache.read("#{cache_key}/#{page.cache_key}/download").tap do |downloaded_page|
        mechanize_page = Mechanize::Page.new(
          nil,
          { 'content-type' => 'text/html' },
          downloaded_page,
          nil,
          Mechanize.new
        )

        noko_doc = Nokogiri::HTML.parse(mechanize_page.body)
        noko_doc.xpath('//script').remove
        noko_doc.xpath('//style').remove

        page_text = noko_doc.text
      end

      text = Html2Text.convert page_text
      word_values = text.split /\s/
      extracted_words = word_values.map do |word_value|
        word_value.downcase
      rescue StandardError => e
        Rails.logger.info "Could not downcase #{word_value}: #{e.message}"
        word_value
      end

      extracted_words.reject!(&:blank?)
      links = mechanize_page.links
      links&.map do |mechanize_link|
        mechanize_link.resolved_uri.to_s rescue nil
      end.compact

      index_data_map = {}.tap do |map|
        extracted_words.each_with_index do |word, index|
          map[word] ||= {}

          map[word][:word_count] ||= 0
          map[word][:word_count] += 1

          map[word][:next_values] ||= []
          map[word][:next_values] << extracted_words[index + 1]
          map[word][:next_values].compact!

          map[word][:prev_values] ||= []
          map[word][:prev_values] << extracted_words[index - 1]
          map[word][:prev_values].compact!

          map[word][:first_index] ||= index

          map[word][:all_indexes] ||= []
          map[word][:all_indexes] << index
        end
      end

      {
        title: mechanize_page.title,
        links: links,
        total_word_count: extracted_words.size,
        index_data_map: index_data_map
      }
    end

    Services::Cache.write(
      "#{cache_key}/#{page.cache_key}/parse",
      page_content,
      expire_time: 1.week
    )

    Services::Cache.delete("#{cache_key}/#{page.cache_key}/download")
  end

  def index_page(page)
    parsed_page = Services::Cache.read("#{cache_key}/#{page.cache_key}/parse")

    page[:word_count] = parsed_page[:total_word_count]
    page.save!

    raise 'No index data map' if parsed_page[:index_data_map].blank?

    words_strings = parsed_page[:index_data_map].keys
    word_objects = Word.fetch_persisted_objects_for(words_strings)


    index_data_map = parsed_page[:index_data_map]

    page_word_objects = word_objects.map do |word_object|
      index_entry = index_data_map[word_object[:value]]

      next_ids = index_entry[:next_values].map do |word_value|
        word_objects.find{|o| o[:value] == word_value}[:id]
      end

      prev_ids = index_entry[:prev_values].map do |word_value|
        word_objects.find{|o| o[:value] == word_value}[:id]
      end

      {
        page_id: page.id,
        word_id: word_object[:id],
        data: {
          word_count: index_entry[:word_count],
          first_index: index_entry[:first_index],
          all_indexes: index_entry[:all_indexes],
          total_word_count: words_strings.size,
          next_ids: next_ids,
          prev_ids: prev_ids
        },
        created_at: Time.now.utc,
        updated_at: Time.now.utc
      }
    end

    page_word_objects.each_slice(1000) do |slice|
      # index_page_words_on_word_id_and_page_id
      PageWord.upsert_all(
        slice,
        unique_by: :index_page_words_on_word_id_and_page_id
      )
    end

    parsed_page[:links].uniq.each do |link|
      IndexingBatch::CreatePageJob.perform_later link
    end

    page[:download_success] = Time.now.utc
    page.save!

    Services::Cache.delete("#{cache_key}/#{page.cache_key}/parse")

    Rails.logger.info "Successfully indexed #{page[:url_string]}"
  end

  def start!
    raise 'Already running this batch' if currently_running?

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
