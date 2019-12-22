require 'rails_helper'

RSpec.describe Index::PageWord, type: :model do
  let(:page) { Index::Page.create(url_string: 'test.com')}
  let(:word) { Index::Word.create(value: 'someword')}
  it 'can be created with a page and word' do

    Index::PageWord.create(page: page, word: word)
  end
end
