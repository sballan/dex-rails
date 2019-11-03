module Text
  class Doc < ApplicationRecord
    # Not needed, but here for clarity
    # self.table_name = 'docs'

    has_many :matches
    has_and_belongs_to_many :pages
  end
end




# class Doc::Doc < ApplicationRecord
#   has_many :matches
#   has_and_belongs_to_many :pages
# end
