class Crawler::UrlWord < ApplicationRecord
  belongs_to :url
  belongs_to :word
end
