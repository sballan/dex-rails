class Index::Download < ApplicationRecord
  belongs_to :page, class_name: 'Index::Page', foreign_key: :index_page_id

  validates :content, presence: true

  validate :mechanize_page_is_valid, on: :create

  def mechanize_page_is_valid
    errors.add(:base, 'Mechanize page must be valid') unless mechanize_page.is_a?(Mechanize::Page)
  end

  # @return [Mechanize::Page]
  def mechanize_page
    return nil unless content.present?

    Mechanize::Page.new(
      nil,
      { 'content-type' => 'text/html' },
      content,
      nil,
      Mechanize.new
    )
  end
end
