class Index::Page < ApplicationRecord
  belongs_to :index_host, class_name: 'Index::Host'
end
