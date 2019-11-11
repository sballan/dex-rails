class Word < ApplicationRecord
  include Redis::Objects

  has_many :page_words, dependent: :destroy
  has_many :pages, through: :page_words

  validates :value, presence: true, uniqueness: true

  # serialize :freq_map, JSON

end
