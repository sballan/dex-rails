class Crawler::Word < ApplicationRecord
  has_many :url_words
  has_many :urls, through: :url_words, source: :word

  validates :value, presence: true, uniqueness: true
end
