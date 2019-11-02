class Url < ApplicationRecord
  has_many :pages

  validates :value, presence: true

  def mechanize_page
    require 'mechanize'
    agent = Mechanize.new
    page = agent.get(value)
    return nil unless page.is_a? Mechanize::Page
    page
  rescue => e
    Rails.logger.error(e.message)
    nil
  end

end
