class PageFragment < ApplicationRecord
  belongs_to :page
  belongs_to :doc, class_name: "::Text::Doc"
end
