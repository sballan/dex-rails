class Index::Word < ApplicationRecord
  has_many :page_words, class_name: 'Index::PageWord', foreign_key: :index_word_id
  has_many :pages,  class_name: 'Index::Page', through: :page_words

  validates :value, presence: true
end
