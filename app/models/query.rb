# frozen_string_literal: true

class Query < ApplicationRecord
  validates :value, presence: true
end
