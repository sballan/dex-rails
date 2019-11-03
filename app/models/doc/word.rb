module Doc
  class Word < Base
    has_and_belongs_to_many :pages
  end
end

# class Doc::Word < Doc::Doc
#   has_and_belongs_to_many :pages
# end

