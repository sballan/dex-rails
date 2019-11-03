module Doc
  class Base < ApplicationRecord
    self.primary_key = "doc_id"
    self.table_name = "doc"

    has_many :matches
    has_and_belongs_to_many :pages
  end
end




# class Doc::Doc < ApplicationRecord
#   has_many :matches
#   has_and_belongs_to_many :pages
# end
