# frozen_string_literal: true

require 'uri'

# Link class
class Link < ActiveRecord::Base
  validate :uri_is_valid, if: :url
  validates_uniqueness_of :url

  private

  def uri_is_valid
    return if url =~ URI::DEFAULT_PARSER.make_regexp

    errors.add(:url, 'invalid')
    false
  end
end
