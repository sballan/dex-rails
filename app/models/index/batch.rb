# frozen_string_literal: true

class Index::Batch < ApplicationRecord
  has_many :batch_pages, class_name: 'Index::BatchPage', foreign_key: :index_batch_id, dependent: :destroy
  has_many :pages, class_name: 'Index::Page', through: :batch_pages
end
