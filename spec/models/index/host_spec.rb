# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Index::Host, type: :model do
  it 'can be created with a url_string' do
    host = Index::Host.create(url_string: 'test.com')
    expect(host).to be
  end
end
