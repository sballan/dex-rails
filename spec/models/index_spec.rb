require 'rails_helper'

describe Index do
  describe '.mechanize_agent' do
    it 'returns an instance of Mechanize' do
      agent = Index.mechanize_agent
      expect(agent.is_a?(Mechanize)).to eql(true)
    end
  end

  describe '.fetch_page' do
    it 'returns an instance of Mechanize::Page' do
      VCR.use_cassette('pages/soundcloud') do
        page = Index.fetch_page('http://www.soundcloud.com')
        expect(page.is_a?(Mechanize::Page)).to eql(true)
      end
    end
  end

  describe '.all_pages_to_download' do
    it 'returns correct pages' do
      Index::Page.create!(url_string: 'http://www.abc.com', download_success: Time.now.utc)
      page = Index::Page.create!(url_string: 'http://www.xyz.com')

      pages_not_downloaded = Index.all_pages_to_download.to_a

      expect(pages_not_downloaded).to eql([page])
    end
  end

  describe '.all_pages_to_index' do
    it 'returns correct pages' do
      Index::Page.create!(url_string: 'http://www.abc.com', download_success: Time.now.utc, index_success: Time.now.utc)
      page = Index::Page.create!(url_string: 'http://www.xyz.com', download_success: Time.now.utc)

      pages_not_indexed = Index.all_pages_to_index.to_a

      expect(pages_not_indexed).to eql([page])
    end
  end
end
