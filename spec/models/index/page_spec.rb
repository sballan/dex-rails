require 'rails_helper'

RSpec.describe Index::Page, type: :model do
  it 'can be created with a host' do
    host = Index::Host.create!(url_string: 'test.com')
    page = Index::Page.create!(host: host, url_string: 'test.com')
    expect(page).to be
  end

  it 'can be created without a host' do
    page = Index::Page.create!(url_string: 'test.com')
    expect(page).to be
  end

  it 'has links array' do
    page = Index::Page.create!(url_string: 'test.com')
    page.links = ['test1', 'test2']
    page.save!
    expect(page.links.first).to eql('test1')
  end

  it 'can have downloads' do
    page = Index::Page.create!(url_string: 'test.com')
    page.downloads.create!(content: '<html></html>')
    page.save!
    expect(page.downloads.first).to be
  end

  describe '.not_downloaded' do
    it 'returns correct pages' do
      Index::Page.create!(url_string: 'http://www.abc.com', download_success: Time.now.utc)
      page = Index::Page.create!(url_string: 'http://www.xys.com')

      pages_not_downloaded = Index::Page.not_downloaded.to_a

      expect(pages_not_downloaded).to eql([page])
    end
  end

  describe '#fetch_page' do
    it 'can download a page' do
      page = Index::Page.create!(url_string: 'http://www.wikipedia.org')

      VCR.use_cassette('pages/wikipedia') do
        page.fetch_page
      end

      expect(page.downloads.first).to be
    end
  end

  describe '#most_recent_download' do
    it 'returns correct download' do
      page = Index::Page.create!(url_string: 'http://www.soundcloud.com')

      VCR.use_cassette('pages/soundcloud') do
        page.fetch_page
        page.fetch_page
      end

      expect(page.downloads.count).to eql(2)
      expect(page.most_recent_download.id).to eql(page.downloads.pluck(:id).max)
    end
  end
end