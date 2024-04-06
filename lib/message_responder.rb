# frozen_string_literal: true

require './models/user'
require './lib/message_sender'
require './lib/chatgpt_client'

# Responder for Messages
class MessageResponder
  attr_reader :message, :bot, :user, :chatgpt

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]

    @chatgpt = ChatgptClient.new
    @user = User.find_or_create_by(uid: message.from.id)
  end

  def respond
    on /^\/help/ do
      answer_with_help_message
      return
    end

    on /^\/start/ do
      answer_with_greeting_message
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /(\.*)/ do |message|
      talk_to_chatgpt(message)
    end
  end

  private

  def on(regex, &block)
    regex =~ message.text
    return unless $LAST_MATCH_INFO

    case block.arity
    when 0
      yield
    when 1
      yield message
    when 2
      yield ::Regexp.last_match(1), ::Regexp.last_match(2)
    end
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_help_message
    answer_with_message I18n.t('help_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def talk_to_chatgpt(message)
    response = chatgpt.response(message)
    answer_with_message(response['choices'][0]['message']['content'])
  end
end
