# frozen_string_literal: true

class Index::Download < ApplicationRecord
  belongs_to :page, class_name: 'Index::Page', foreign_key: :index_page_id

  validates :content, presence: true

  validate :mechanize_page_is_valid, on: :create

  def mechanize_page_is_valid
    errors.add(:base, 'Mechanize page must be valid') unless mechanize_page.is_a?(Mechanize::Page)
  end

  def generate_words_map
    word_values = page_text.split /\s/
    extracted_words = word_values.map do |word_value|
      word_value.downcase
    rescue StandardError => e
      Rails.logger.info "Could not downcase #{word_value}: #{e.message}"
      word_value
    end

    extracted_words.reject!(&:blank?)

    {}.tap do |map|
      extracted_words.each_with_index do |word, index|
        map[word] ||= {}

        map[word][:word_count] ||= 0
        map[word][:word_count] += 1

        map[word][:next_values] ||= []
        map[word][:next_values] << extracted_words[index + 1]
        map[word][:next_values].compact!

        map[word][:prev_values] ||= []
        map[word][:prev_values] << extracted_words[index - 1]
        map[word][:prev_values].compact!

        map[word][:first_index] ||= index

        map[word][:all_indexes] ||= []
        map[word][:all_indexes] << index
      end
    end
  end

  def page_text
    doc = mechanize_page.parser
    doc.xpath('//script').remove
    doc.xpath('//style').remove

    Html2Text.convert doc.to_html.force_encoding('UTF-8')
  end

  def links
    mechanize_page.links&.map do |mechanize_link|
      mechanize_link.resolved_uri.to_s
    rescue StandardError
      nil
    end.compact
  end

  def title
    mechanize_page.title
  end

  # @return [Mechanize::Page]
  def mechanize_page
    return @mechanize_page unless @mechanize_page.nil?
    return nil if content.blank?

    @mechanize_page = Mechanize::Page.new(
      nil,
      { 'content-type' => 'text/html' },
      content,
      nil,
      Mechanize.new
    )
  end
end
