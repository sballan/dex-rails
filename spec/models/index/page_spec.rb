require 'rails_helper'

RSpec.describe Index::Page, type: :model do
  it 'has a host' do
    host = Index::Host.create(url_string: 'test.com')
    page = Index::Page.create(index_host: host, url_string: 'test.com')
    expect(page).to be
  end
end
