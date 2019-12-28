# frozen_string_literal: true

FactoryBot.define do
  factory :index_word, class: 'Index::Word' do
    value { Faker::Hipster.unique.word }
  end
end
