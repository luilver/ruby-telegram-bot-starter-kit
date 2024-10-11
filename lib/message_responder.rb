# frozen_string_literal: true

require './models/user'
require './lib/chatgpt_client'
require './lib/message_sender'
require './lib/scraper'

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
    on(%r{^/help}) do
      return answer_with_help_message
    end

    on(%r{^/tldr(\.*)}) do |message|
      return answer_with_error(:tldr) unless message.split[1]

      return answer_with_tldr(message.strip)
    end

    on(%r{^/ask(\.*)}) do |message|
      talk_to_chatgpt(message.strip)
    end

    on(%r{^/cibercuba}) do
      scrape_save_and_answer
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

  def answer_with_tldr(message, link = nil)
    response = chatgpt.tldr(message)

    tldr = response['choices'][0]['message']['content'] if response
    tldr += "\n\n#{link}" if link
    answer_with_message(tldr)
  end

  def build_tme_link(link)
    "https://t.me/iv?url=#{link}"
  end

  def scrape_save_and_answer
    valid_records = false

    feeds = Scraper.run
    feeds.each do |link|
      record = Link.create(url: link)
      valid_records ||= record.valid?
      answer_with_tldr("/tldr #{build_tme_link(link)}", link) if record.valid?
    end

    answer_with_message I18n.t('no_new_links') unless valid_records
  end

  def talk_to_chatgpt(message)
    response = chatgpt.response(message)

    answer_with_message(response['choices'][0]['message']['content']) if response
  end
end
