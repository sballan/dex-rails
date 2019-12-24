class Index::Page < ApplicationRecord
  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id
  has_many :downloads, class_name: 'Index::Download', foreign_key: :index_page_id, dependent: :destroy
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_page_word_id

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

    downloads.create!(content: mechanize_page.body)
  end
end
