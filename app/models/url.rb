class Url < ApplicationRecord
  has_many :pages

  validates :value, presence: true

  def mechanize_page
    require 'mechanize'
    agent = Mechanize.new
    agent.get(value)
  rescue => ex
    Rails.logger.error ex.message
    nil
  end

end
