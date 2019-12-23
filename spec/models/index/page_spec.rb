require 'rails_helper'

RSpec.describe Index::Page, type: :model do
  it 'can be created with a host' do
    host = Index::Host.create!(url_string: 'test.com')
    page = Index::Page.create!(host: host, url_string: 'test.com')
    expect(page).to be
  end

  it 'can be created without a host' do
    page = Index::Page.create!(url_string: 'test.com')
    expect(page).to be
  end

  it 'has links array' do
    page = Index::Page.create!(url_string: 'test.com')
    page.links = ['test1', 'test2']
    page.save!
    expect(page.links.first).to eql('test1')
  end

  it 'can have downloads' do
    page = Index::Page.create!(url_string: 'test.com')
    page.downloads.create!(content: '<html></html>')
    page.save!
    expect(page.downloads.first).to be
  end

end
