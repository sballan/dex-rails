class Url < ApplicationRecord
  validates :value, presence: true

  def fetch
    require 'mechanize'
    agent = Mechanize.new
    agent.get(value)
  end

end
