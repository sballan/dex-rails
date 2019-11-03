# there should be a match for every possible substring

class Match < ApplicationRecord
  belongs_to :query   # input to match against
  belongs_to :page    # the
  belongs_to :doc, class_name: '::Docs::Base'
end
