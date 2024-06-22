# frozen_string_literal: true

require './models/user'
require './lib/message_sender'
require './lib/chatgpt_client'

# Responder for Messages
class MessageResponder
  attr_reader :event, :bot, :user, :chatgpt, :message_id

  def initialize(options)
    I18n.locale = :es

    @bot = options[:bot]
    @event = options[:event]
    @message_id = event.message_id

    @chatgpt = ChatgptClient.new
    @user = User.find_or_create_by(uid: event.from.id)
  end

  def respond
    on /^\/help/ do
      return answer_with_help_message
    end

    on /^\/tldr(\.*)/ do |message|
      return answer_with_error(:tldr) unless message.split[1]

      return answer_with_tldr(message.strip)
    end

    on /^\/ask(\.*)/ do |message|
      talk_to_chatgpt(message.strip)
    end
  end

  private

  def on(regex, &block)
    regex =~ event.text
    return unless $LAST_MATCH_INFO

    case block.arity
    when 0
      yield
    when 1
      yield event.text
    when 2
      yield ::Regexp.last_match(1), ::Regexp.last_match(2)
    end
  end

  def answer_with_error(symbol)
    answer_with_message I18n.t("error_message_#{symbol}")
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
    MessageSender.new(bot:, chat: event.chat, text:, message_id:).send
  end

  def answer_with_tldr(link)
    response = chatgpt.tldr(link)

    answer_with_message(response['choices'][0]['message']['content']) if response
  end

  def talk_to_chatgpt(message)
    response = chatgpt.response(message)

    answer_with_message(response['choices'][0]['message']['content']) if response
  end
end
