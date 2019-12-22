require 'rails_helper'

RSpec.describe Index::Page, type: :model do
  let(:host) { Index::Host.create(url_string: 'test.com') }
  it 'has a host' do
    page = Index::Page.create(index_host: host, url_string: 'test.com')
    expect(page).to be
  end

  it 'has links array' do
    page = Index::Page.create(index_host: host, url_string: 'test.com')
    page.links = ['test1', 'test2']
    page.save
    expect(page.links.first).to eql('test1')
  end
end
