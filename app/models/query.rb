class Query < ApplicationRecord
  validates :value, presense: true
end
