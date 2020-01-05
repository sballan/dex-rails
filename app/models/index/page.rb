# frozen_string_literal: true

class Index::Page < ApplicationRecord
  class FetchInvalidError < StandardError; end
  class FetchFailureError < StandardError; end
  class IndexInvalidError < StandardError; end

  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id
  has_many :downloads, class_name: 'Index::Download', foreign_key: :index_page_id, dependent: :destroy
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_page_id, dependent: :destroy

  # @deprecated
  scope :not_fetched, -> { where(download_success: nil, download_invalid: nil) }
  # @deprecated
  scope :not_indexed, -> { where(index_success: nil) }

  scope :to_fetch, lambda {
    where(
      download_success: nil,
      download_invalid: nil
    )
  }

  scope :to_index, lambda {
    where(
      index_success: nil,
      index_invalid: nil
    ).where.not(
      download_success: nil
    )
  }

  validates :url_string, presence: true

  before_validation do
    if host.blank?
      uri = URI(self[:url_string])
      host_url_string = "#{uri.scheme}://#{uri.host}"
      self.host ||= Index::Host.find_or_create_by url_string: host_url_string
    end
  end

  def most_recent_download
    downloads.order(created_at: :desc).first
  end

  def fetch_page
    mechanize_page = Index.fetch_page(url_string)
    raise FetchFailureError, 'Page is nil' if mechanize_page.nil?
    raise FetchInvalidError, 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

    download_content = mechanize_page.body.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    raise FetchInvalidError, 'Page is blank' if download_content.blank?

    download = downloads.create!(content: download_content)

    with_lock do
      update_links!(download.links)
      update_title!(download.title)
    end

    self[:download_success] = Time.now.utc
    save!
  rescue Mechanize::ResponseCodeError => e
    # raise e unless %w[500 410 409 404 403 400].include?(e.response_code)

    self[:download_invalid] = Time.now.utc
    save!
  rescue FetchInvalidError, Mechanize::RobotsDisallowedError, Mechanize::RedirectLimitReachedError
    self[:download_invalid] = Time.now.utc
    save!
  rescue StandardError
    self[:download_failure] = Time.now.utc
    save!

    raise
  end

  def index_page
    raise "can't index before download" unless downloads.any?

    generate_page_word_data.each_slice(200) do |slice|
      Index::PageWord.upsert_all(
        slice,
        unique_by: :index_index_page_words_on_index_word_id_and_index_page_id
      )
    end

    self[:index_success] = Time.now.utc
    save!
  rescue IndexInvalidError
    self[:index_invalid] = Time.now.utc
    save!
  rescue StandardError
    self[:index_failure] = Time.now.utc
    save!

    raise
  end

  def generate_page_word_data
    begin
      words_map = most_recent_download.generate_words_map
    rescue ArgumentError => e
      raise e unless e.message == 'invalid byte sequence in UTF-8'

      raise IndexInvalidError, 'Encountered invalid byte sequence in UTF-8 while trying to index'
    end

    words_map.map do |word_value, data|
      word_id = Index.word_id_cache(word_value)
      {
        index_word_id: word_id,
        index_page_id: id,
        data: data,
        created_at: Time.now.utc,
        updated_at: Time.now.utc
      }
    end
  end

  def update_title!(title)
    self[:data] ||= {}
    self[:data]['title'] = title
  end

  def update_links!(links)
    self[:data] ||= {}
    self[:data]['links'] = links.uniq
  end
end
