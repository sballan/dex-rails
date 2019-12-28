# frozen_string_literal: true

class Index::Host < ApplicationRecord
  validates :url_string, presence: true
end
