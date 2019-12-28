# frozen_string_literal: true

class Index::Page < ApplicationRecord
  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id
  has_many :downloads, class_name: 'Index::Download', foreign_key: :index_page_id, dependent: :destroy
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_page_id, dependent: :destroy

  scope :not_fetched, -> { where(download_success: nil, download_invalid: nil) }
  scope :not_indexed, -> { where(index_success: nil) }

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
    raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

    download = downloads.create!(content: mechanize_page.body.force_encoding('UTF-8'))

    with_lock do
      update_links!(download.links)
      update_title!(download.title)
    end

    self[:download_success] = Time.now.utc
    save!
  rescue Mechanize::RobotsDisallowedError
    self[:download_failure] = Time.now.utc
    self[:download_invalid] = Time.now.utc
    save!
  rescue StandardError
    self[:download_failure] = Time.now.utc
    save!
  end

  def index_page
    raise "can't index before download" unless downloads.any?

    generate_page_word_data.each_slice(500) do |slice|
      Index::PageWord.upsert_all(
        slice,
        unique_by: :index_index_page_words_on_index_word_id_and_index_page_id
      )
    end

    self[:index_success] = Time.now.utc
    save!
  rescue StandardError
    self[:index_failure] = Time.now.utc
    save!
  end

  def generate_page_word_data
    words_map = most_recent_download.generate_words_map

    words_map.map do |word_value, data|
      word_id = Index.word_cache(word_value).id
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
