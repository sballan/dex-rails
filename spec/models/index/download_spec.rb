# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Download, type: :model do
  after(:all) do
    Index::Page.destroy_all
  end

  let(:page) do
    Index::Page.create!(url_string: 'test.com')
  end

  it 'can be created with a page' do
    download = Index::Download.create!(page: page, content: '<html></html>')
    expect(download).to be
  end

  describe '#links' do
    it 'returns the links' do
      download = Index::Download.create!(
        page: page,
        content: '<html><body><a href="https://www.abc.com">My Link</a></body></html>'
      )

      expect(download.links).to eql(["https://www.abc.com/"])
    end
  end

  describe '#title' do
    it 'returns the links' do
      download = Index::Download.create!(
        page: page,
        content: '<html><title>My Title</title></html>'
      )

      expect(download.title).to eql('My Title')
    end
  end

  describe '#generate_words_map' do
    let(:expected_words_map) do
      {
        'words' => {
          word_count: 2,
          next_values: ['are', 'here'],
          prev_values: ['here', 'are'],
          first_index: 0,
          all_indexes: [0, 2]
        },
        'are' => {
          word_count: 1,
          next_values: ['words'],
          prev_values: ['words'],
          first_index: 1,
          all_indexes: [1]
        },
        'here' => {
          word_count: 1,
          next_values: [],
          prev_values: ['words'],
          first_index: 3,
          all_indexes: [3]
        }
      }
    end
    it 'returns the map' do
      download = Index::Download.create!(page: page, content: '<html>words are words here</html>')
      words_map = download.generate_words_map
      expect(words_map).to eql(expected_words_map)
    end
  end
end
