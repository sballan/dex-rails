require 'rails_helper'

RSpec.describe Index::Word, type: :model do
  it 'can be created with a value' do
    word = Index::Word.create!(value: 'test')
    expect(word).to be
  end

  it 'can have page_words' do
    page = Index::Page.create(url_string: 'test.com')
    word = Index::Word.create!(value: 'test')
    word.page_words.create page: page
  end
end
