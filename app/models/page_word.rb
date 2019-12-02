# frozen_string_literal: true

class PageWord < ApplicationRecord
  include Redis::Objects

  belongs_to :page
  belongs_to :word

  validates :page_count, presence: true
end
