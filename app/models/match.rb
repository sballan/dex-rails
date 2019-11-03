# there should be a match for every possible substring

class Match < ApplicationRecord
  belongs_to :query   # input to match against
  belongs_to :page
  belongs_to :doc
end
