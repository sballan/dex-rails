class Word < ApplicationRecord
  has_many :page_words
  has_many :pages, through: :page_words

  validates :value, presence: true, uniqueness: true

  # serialize :freq_map, JSON
end
