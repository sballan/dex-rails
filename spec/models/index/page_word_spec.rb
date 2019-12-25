# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::PageWord, type: :model do
  after(:all) do
    Index::Page.destroy_all
    Index::Word.destroy_all
  end

  let(:page) { Index::Page.create(url_string: 'test.com')}
  let(:word) { Index::Word.create(value: 'someword')}
  it 'can be created with a page and word' do
    page_word = Index::PageWord.create(page: page, word: word)
    expect(page_word).to be
  end
end
