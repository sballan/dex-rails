class Index::PageWord < ApplicationRecord
  belongs_to :page, class_name: 'Index::Page', foreign_key: :index_page_id
  belongs_to :word, class_name: 'Index::Word', foreign_key: :index_word_id
end
