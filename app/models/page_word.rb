class PageWord < ApplicationRecord
  include Redis::Objects

  belongs_to :url
  belongs_to :word

  validates :word_count, presence: true
  validates :page_count, presence: true
end
