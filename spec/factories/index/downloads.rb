# frozen_string_literal: true

require 'vcr'

page_url_strings = [
  'https://soundcloud.com/vulfpeck',
  'https://www.starwars.com/community',
  'https://arstechnica.com',
  'https://www.atlasobscura.com',
  'https://www.bbc.com/news/science_and_environment',
  'https://www.chemistryworld.com',
  'https://futurism.com',
  'https://gizmodo.com',
  'https://www.npr.org/sections/science/'
]

FactoryBot.define do
  factory :index_download, class: 'Index::Download' do
    association :page, factory: :index_page
    sequence :content do |n|
      mod = n % page_url_strings.size
      VCR.use_cassette('factories/download') do
        agent = Mechanize.new
        mechanize_page = agent.get(page_url_strings[mod])
        raise 'Only html pages are supported' unless mechanize_page.is_a?(Mechanize::Page)

        mechanize_page.body.force_encoding('UTF-8')
      end
    end
  end
end


