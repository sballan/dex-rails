class Index::Word < ApplicationRecord
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_word_id

  validates :value, presence: true
end
