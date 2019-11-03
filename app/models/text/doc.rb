module Text
  class Doc < ApplicationRecord
    self.table_name = 'text_docs'

    has_many :matches
    has_and_belongs_to_many :pages
  end
end




# class Doc::Doc < ApplicationRecord
#   has_many :matches
#   has_and_belongs_to_many :pages
# end
