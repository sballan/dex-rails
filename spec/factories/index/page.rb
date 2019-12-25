# frozen_string_literal: true

FactoryBot.define do
  factory :index_page, class: 'Index::Page' do
    url_string { Faker::Internet.unique.url }
  end
end
