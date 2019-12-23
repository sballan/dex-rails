# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Host, type: :model do
  it 'can be created with a url_string' do
    host = Index::Host.create(url_string: 'test.com')
    expect(host).to be
  end

  it 'can have a pages_to_index array' do
    host = Index::Host.create(url_string: 'test.com')
    host.with_lock(true) do
      host.pages_to_index.concat [1, 2]
      host.save
    end
    expect(host.pages_to_index).to eql([1, 2])
  end

  it 'can have a pages_indexed array' do
    host = Index::Host.create(url_string: 'test.com', pages_to_index: [1, 2])
    host.with_lock(true) do
      indexed_page = host.pages_to_index.shift
      host.pages_indexed << indexed_page
      host.save
    end
    expect(host.pages_to_index).to eql([2])
    expect(host.pages_indexed).to eql([1])
  end
end
