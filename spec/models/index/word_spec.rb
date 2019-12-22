require 'rails_helper'

RSpec.describe Index::Word, type: :model do
  it 'can be created with a value' do
    word = Index::Word.create(value: 'test')
    expect(word).to be
  end
end
