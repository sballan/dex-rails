# frozen_string_literal: true

FactoryBot.define do
  factory :index_page_word, class: 'Index::PageWord' do
    association :page, factory: :index_page
    association :word, factory: :index_word
  end
end
