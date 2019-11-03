class Query < ApplicationRecord
  validates :value, presence: true

  def process_async

  end
end
