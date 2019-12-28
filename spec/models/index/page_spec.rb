# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Page, type: :model do
  context 'creation' do
    after(:each) do
      Index::Page.destroy_all
      Index::Host.destroy_all
      Index::Word.destroy_all
    end

    it 'can be created with a host' do
      host = Index::Host.create!(url_string: 'test.com')
      page = Index::Page.create!(host: host, url_string: 'test.com')
      expect(page).to be
    end

    it 'can be created without a host' do
      page = Index::Page.create!(url_string: 'test.com')
      expect(page).to be
    end

    it 'can have downloads' do
      page = Index::Page.create!(url_string: 'test.com')
      page.downloads.create!(content: '<html></html>')
      page.save!
      expect(page.downloads.first).to be
    end

    it 'can have page_words' do
      page = Index::Page.create!(url_string: 'test.com')
      page.page_words.create(word: Index::Word.create(value: 'test'))
      page.save!
      expect(page.page_words.first).to be
    end
  end

  describe '.not_fetched' do
    after(:all) do
      Index::Page.destroy_all
    end

    it 'returns correct pages' do
      Index::Page.create!(url_string: 'http://www.abc.com', download_success: Time.now.utc)
      page = Index::Page.create!(url_string: 'http://www.xys.com')

      pages_not_fetched = Index::Page.not_fetched.to_a

      expect(pages_not_fetched).to eql([page])
    end
  end

  describe '.not_indexed' do
    after(:all) do
      Index::Page.destroy_all
    end

    it 'returns correct pages' do
      Index::Page.create!(url_string: 'http://www.abc.com', index_success: Time.now.utc)
      page = Index::Page.create!(url_string: 'http://www.xys.com')

      pages_not_indexed = Index::Page.not_indexed.to_a

      expect(pages_not_indexed).to eql([page])
    end
  end

  describe '#most_recent_download' do
    before(:all) do
      @page = Index::Page.create!(url_string: 'http://www.soundcloud.com')

      VCR.use_cassette('pages/soundcloud') do
        @page.fetch_page
        @page.fetch_page
      end
    end

    after(:all) do
      Index::Page.destroy_all
    end

    it 'returns correct download' do
      expect(@page.downloads.count).to eql(2)
      expect(@page.most_recent_download.id).to eql(@page.downloads.pluck(:id).max)
    end
  end

  describe '#fetch_page' do
    before(:all) do
      @page = Index::Page.create!(url_string: 'http://www.wikipedia.org')

      VCR.use_cassette('pages/wikipedia') do
        @page.fetch_page
      end
    end

    after(:all) do
      Index::Page.destroy_all
    end

    it 'can download a page' do
      expect(@page.downloads.first).to be
    end

    it 'has title' do
      expect(@page.data['title']).to eql('Wikipedia')
    end

    it 'has links' do
      expect(@page.data['links'].last).to eql('https://creativecommons.org/licenses/by-sa/3.0/')
    end
  end

  describe '#index_page' do
    before(:all) do
      @page = Index::Page.create!(url_string: 'http://www.wikipedia.org')

      VCR.use_cassette('pages/wikipedia') do
        @page.fetch_page
      end
    end

    after(:all) do
      Index::Page.destroy_all
    end

    it 'can index a page' do
      @page.index_page
      expect(@page.page_words.first).to be
    end
  end
end
