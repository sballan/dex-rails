class PageWord < ApplicationRecord
  include Redis::Objects

  belongs_to :page, touch: true
  belongs_to :word, touch: true # word caches page_words, so we need to touch it to invalidate its cache

  validates :page_count, presence: true
end
