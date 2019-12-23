class Index::Page < ApplicationRecord
  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id
  has_many :downloads, class_name: 'Index::Download', foreign_key: :index_page_id, dependent: :destroy

  validates :url_string, presence: true

  before_validation do
    if host.blank?
      uri = URI(self[:url_string])
      host_url_string = "#{uri.scheme}://#{uri.host}"
      self.host ||= Index::Host.find_or_create_by url_string: host_url_string
    end
  end

  def fetch_page
    agent = Index.mechanize_agent
    mechanize_page = agent.get(self[:url_string])
    raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

    mechanize_page
  end
end
