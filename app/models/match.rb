class Match < ApplicationRecord
  belongs_to :query
  belongs_to :doc_base
  belongs_to :page
end
