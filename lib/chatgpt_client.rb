# frozen_string_literal: true

require 'chatgpt/client'
require 'nokogiri'
require 'open-uri'
require 'uri'

# Client for ChatGPT
class ChatgptClient
  BBC_MUNDO_SEPARATOR = "window\."
  BBC_MUNDO_REGEXP = %r{https://www.bbc.com/mundo}
  CC_BODY_SEPARATOR = "unknown\."
  CC_REGEXP = %r{https://www.cibercuba.com}

  attr_reader :client, :api_key

  def initialize(options = {})
    config = YAML.safe_load(IO.read('config/secrets.yml'))

    @api_key = options[:api_key] || config['chatgpt_api_key']
    @client = options[:client] || ChatGPT::Client.new(api_key)
  end

  def response(message)
    client.chat(prompt(message))
  end

  def text_from(url)
    html_content = URI.open(url).read
    doc = Nokogiri::HTML(html_content)

    doc.css('body').text.strip
  rescue OpenURI::HTTPError => e
    puts "HTTP Error: #{e.message}"
    nil
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
    nil
  end

  def tldr(message)
    # validate link
    link = message.split(' ')[1..][0] if BBC_MUNDO_REGEXP =~ message
    link = message.split(' ')[1..][0].split("=")[1] if CC_REGEXP =~ message
    return unless valid_url?(link)

    body_separator = BBC_MUNDO_SEPARATOR if BBC_MUNDO_REGEXP =~ link
    body_separator = CC_BODY_SEPARATOR if CC_REGEXP =~ link

    text = text_from(link).split(body_separator)[0]

    summary = summarized(text)
    prompter = prompt(summary)

    client.chat(prompter)
  end

  def prompt(content)
    [
      {
        role: 'user',
        content:
      }
    ]
  end

  private

  def summarized(text)
    return unless text

    "Resume el siguiente texto: #{text}"
  end

  def valid_url?(url)
    url_regex = /\A#{URI::regexp(['http', 'https'])}\z/
    url_regex.match?(url)
  end
end
