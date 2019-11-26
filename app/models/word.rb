class Word < ApplicationRecord
  include Redis::Objects

  has_many :page_words, dependent: :destroy
  has_many :pages, through: :page_words

  validates :value, presence: true

  def cache_db_pages
    Rails.cache.fetch("#{cache_key_with_version}/db_pages") do
      self.pages
    end
  end

  def cache_page_db_words
    Rails.cache.fetch("#{cache_key_with_version}/page_db_words") do
      self.page_words
    end
  end

  # serialize :freq_map, JSON

end
