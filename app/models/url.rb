class Url < ApplicationRecord
  has_many :pages

  validates :value, presence: true

  def fetch
    require 'mechanize'
    agent = Mechanize.new
    agent.get(value)
  end

end
