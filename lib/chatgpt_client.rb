# frozen_string_literal: true

require 'chatgpt/client'
require 'nokogiri'
require 'open-uri'
require 'uri'

# Client for ChatGPT
class ChatgptClient
  attr_reader :client, :api_key

  def initialize(options = {})
    config = YAML.safe_load(IO.read('config/secrets.yml'))

    @api_key = options[:api_key] || config['chatgpt_api_key']
    @client = options[:client] || ChatGPT::Client.new(api_key)
  end

  def response(message)
    client.chat(prompt(message.text))
  end

  def tldr(link)
    return unless valid_url?(link)

    client.chat(prompt(summarized(fetch_and_parse(link))))
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

  def fetch_and_parse(url)
    html_content = open(url)

    parsed_content = Nokogiri::HTML(html_content)

    body = parsed_content.at('body')
    body_content = body ? body.inner_html : "No body found"

    body_content
  end

  def summarized(text)
    return unless text

    "Resume el siguiente texto: #{text}"
  end

  def valid_url?(url)
    url_regex = /\A#{URI::regexp(['http', 'https'])}\z/
    url_regex.match?(url)
  end
end
