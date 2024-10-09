# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

# Scraper
class Scraper
  # URL of CiberCuba's news page
  URL = 'https://www.cibercuba.com/'

  attr_reader :feeds

  def self.run
    feeds = []

    # Fetch and parse HTML document
    html = URI.open(URL)
    doc = Nokogiri::HTML(html)

    # Scrape the latest 3 articles (adjust as necessary)
    # articles = doc.css('.news-list .article-item')
    articles = doc.css('div.caption')

    # Print the titles and URLs of the latest 3 articles
    articles.first(10).each_with_index do |article, _index|
      link = article.css('a').first['href']

      feeds << "https://www.cibercuba.com#{link}"
    end

    feeds.uniq
  end
end
