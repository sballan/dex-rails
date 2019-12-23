require 'rails_helper'

RSpec.describe Index::Download, type: :model do
  it 'can be created with a page' do
    page = Index::Page.create!(url_string: 'test.com')
    download = Index::Download.create!(page: page, content: '<html></html>')
    expect(download).to be
  end
end
