# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Batch, type: :model do
  after(:all) do
    Index::Page.destroy_all
    Index::Batch.destroy_all
  end

  it 'can be created' do
    batch = Index::Batch.create
    expect(batch).to be
  end

  describe '#run' do
    let(:pages) do
      [
        Index::Page.create(url_string: 'https://harrypotter.fandom.com/wiki/Main_Page'),
        Index::Page.create(url_string: 'https://en.wikipedia.org/wiki/Star_Wars'),
        Index::Page.create(url_string: 'https://soundcloud.com/vulfpeck'),
        Index::Page.create(url_string: 'https://www.starwars.com/community'),
        Index::Page.create(url_string: 'https://fanlore.org/wiki/His_Dark_Materials')
      ]
    end

    let(:batch) do
      Index::Batch.create
    end

    it 'properly runs' do
      pages.each do |page|
        batch.batch_pages.create(page: page)
      end

      VCR.use_cassette('batches/full_run') do
        ActiveRecord::Base.logger.silence do
          # do a lot of querys without noisy logs
          batch.run_now
        end
      end
    end
  end
end
