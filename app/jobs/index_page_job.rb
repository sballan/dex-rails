# frozen_string_literal: true

class IndexPageJob < ApplicationJob
  queue_as :indexing

  discard_on Page::BadCrawl

  # @param [Page] page
  def perform(page)
    Rails.logger.info "Attempting page index for: #{page.url_string}"

    unless page.index_allowed?
      Rails.logger.error "Not indexing, index not allowed for #{page.url_string}"
      return
    end

    unless page.recently_indexed?(5.minutes)
      Rails.logger.warn "Not indexing, indexed too recently: #{page.url_string}"
      return
    end

    extracted_words_map = {}.tap do |map|
      page.content['extracted_words'].each do |extracted_word|
        map[extracted_word] ||= 0
        map[extracted_word] += 1
      end
    end

    words_strings = extracted_words_map.keys

    # Find db words that exist
    Rails.logger.info "Plucking #{words_strings} words"
    plucked_words = Word.where(value: words_strings)
                        .pluck(:id, :value)
                        .map { |v| { id: v[0], value: v[1] } }

    missing_words_strings = words_strings - plucked_words.map { |plucked_word| plucked_word[:value] }

    missing_words_objects = missing_words_strings.map { |w| { value: w } }
    created_words = missing_words_objects.map do |word_object|
      Word.create_or_find_by! word_object
    end

    created_words.map! { |word| { id: word.id, value: word.value } }
    plucked_words.concat(created_words)

    plucked_words.map do |word|
      page_count = extracted_words_map[word[:value]]
      IndexPageWordJob.perform_later(page.id, word[:id], page_count: page_count)
    end

    # page_words = plucked_words.map do |word|
    #   page_word = PageWord.create_or_find_by! word_id: word[:id], page: page
    #   page_word[:page_count] = extracted_words_map[word[:value]]
    #   page_word.save!
    # end
    #
    # Rails.logger.info "mapped #{page_words.size} page_words"
  end

  def should_index?(page)
    unless page.host.allowed?(page[:url_string])
      Rails.logger.warn "Not allowed to index Host: #{page.host.host_url_string}"
      return false
    end

    if page.host.rate_limit_reached?
      Rails.logger.warn "Rate limit reached for Host: #{page.host.host_url_string}"
      return false
    end

    last_success = page[:download_success].to_i || 0
    last_failure = page[:download_failure].to_i || 0
    last_invalid = page[:download_invalid].to_i || 0

    last_download = [last_success, last_failure, last_invalid].max

    if Time.now < last_download + page.host.success_retry_seconds
      Rails.logger.warn "Index not allowed, download too recent: #{last_download}"
      return false
    else
      Rails.logger.debug "Index allowed, last_download: #{last_download}"
    end

    if page.content.blank? || page.content['extracted_words'].blank?
      Rails.logger.info "Attempting to download page before indexing: #{page.url_string}"
      Services::PageCrawl.persist_page_content(page)

      # Rails.logger.debug "Start Collecting garbage: #{page.url_string}"
      # GC.start(full_mark: true, immediate_sweep: true)
      # Rails.logger.debug "Start Collecting garbage: #{page.url_string}"
    end

    true
  end
end
