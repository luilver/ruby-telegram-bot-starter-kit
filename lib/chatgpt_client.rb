# frozen_string_literal: true

require 'chatgpt/client'

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

  def prompt(content)
    [
      {
        role: 'user',
        content:
      }
    ]
  end
end
