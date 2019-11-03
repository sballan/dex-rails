class Url < ApplicationRecord
  has_many :pages

  validates :value, presence: true
end
