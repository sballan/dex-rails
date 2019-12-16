# frozen_string_literal: true

class PageWord < ApplicationRecord
  belongs_to :page
  belongs_to :word
end
