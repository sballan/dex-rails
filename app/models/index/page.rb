class Index::Page < ApplicationRecord
  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id
  has_many :downloads, class_name: 'Index::Download', foreign_key: :index_page_id, dependent: :destroy
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_page_id, dependent: :destroy

  scope :not_downloaded, -> { where(download_success: nil) }

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

    downloads.create!(content: mechanize_page.body.force_encoding('UTF-8'))

    self[:download_success] = Time.now.utc
    save!
  rescue StandardError
    self[:download_failure] = Time.now.utc
    save!
  end

  def index_page
    raise "can't index before download" unless downloads.any?

    words_map = most_recent_download.generate_words_map

    Index::Word.upsert_all(
      words_map.keys.map { |k| { value: k, created_at: Time.now.utc, updated_at: Time.now.utc } },
      unique_by: :index_index_words_on_value
    )

    page_word_data = []

    Index::Word.where(value: words_map.keys).in_batches.each_record do |word|
      page_word_data << {
        index_word_id: word.id,
        index_page_id: id,
        data: words_map[word.value],
        created_at: Time.now.utc,
        updated_at: Time.now.utc
      }
    end

    page_word_data.each_slice(1000) do |slice|
      Index::PageWord.upsert_all(
        slice,
        unique_by: :index_index_page_words_on_index_word_id_and_index_page_id
      )
    end
  end
end
