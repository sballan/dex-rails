class Index::Page < ApplicationRecord
  belongs_to :host, class_name: 'Index::Host', foreign_key: :index_host_id

  before_validation do
    if host.blank?
      uri = URI(self[:url_string])
      host_url_string = "#{uri.scheme}://#{uri.host}"
      self.host ||= Index::Host.find_or_create_by url_string: host_url_string
    end
  end
end
