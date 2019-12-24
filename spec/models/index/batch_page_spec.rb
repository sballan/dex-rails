# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::BatchPage, type: :model do
  it 'can be created with an Index::Batch and Index::Page' do
    page = Index::Page.create!(url_string: 'http://www.xyz.com')
    batch = Index::Batch.create

    batch_page = Index::BatchPage.create(page: page, batch: batch)
    expect(batch_page).to be
  end

  describe '.not_downloaded' do
    it 'returns correct pages' do
      batch = Index::Batch.create

      Index::BatchPage.create(
        batch: batch,
        page: Index::Page.create!(url_string: 'http://www.abc.com'),
        download_success: DateTime.now.utc
      )
      batch_page2 = Index::BatchPage.create(
        batch: batch,
        page: Index::Page.create!(url_string: 'http://www.xys.com')
      )

      batch_pages_not_downloaded = Index::BatchPage.not_downloaded.to_a

      expect(batch_pages_not_downloaded).to eql([batch_page2])
    end
  end

  describe '.not_indexed' do
    it 'returns correct pages' do
      batch = Index::Batch.create

      Index::BatchPage.create(
        batch: batch,
        page: Index::Page.create!(url_string: 'http://www.abc.com'),
        index_success: DateTime.now.utc
      )
      batch_page2 = Index::BatchPage.create(
        batch: batch,
        page: Index::Page.create!(url_string: 'http://www.xys.com')
      )

      batch_pages_not_indexed = Index::BatchPage.not_indexed.to_a

      expect(batch_pages_not_indexed).to eql([batch_page2])
    end
  end
end
