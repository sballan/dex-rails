# frozen_string_literal: true

page_url_strings = [
  'https://soundcloud.com/vulfpeck',
  'https://www.starwars.com/community',
  'https://arstechnica.com',
  'https://www.atlasobscura.com',
  'https://www.bbc.com/news/science_and_environment',
  'https://www.chemistryworld.com',
  'https://futurism.com',
  'https://gizmodo.com',
  'https://www.npr.org/sections/science'
]

FactoryBot.define do
  factory :index_page, class: 'Index::Page' do
    sequence :url_string do |n|
      mod = n % page_url_strings.size
      u = Random.rand
      "#{page_url_strings[mod]}?u=#{u}&n=#{n}"
    end

    factory :index_page_with_downloads do
      after(:create) do |index_page, evaluator|
        VCR.use_cassette('factories/download', :match_requests_on => [:path]) do
          index_page.fetch_page
        end
      end
    end

  end
end




