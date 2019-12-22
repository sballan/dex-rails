class Index::Word < ApplicationRecord
  validates :value, presence: true
end