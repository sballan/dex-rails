# frozen_string_literal: true

FactoryBot.define do
  factory :index_host, class: 'Index::Host' do
    url_string do
      uri = URI(Faker::Internet.unique.url)
      "#{uri.scheme}://#{uri.host}"
    end
  end
end
