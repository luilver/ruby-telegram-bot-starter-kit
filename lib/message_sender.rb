# frozen_string_literal: true

require './lib/reply_markup_formatter'
require './lib/app_configurator'

# Sender for Messages
class MessageSender
  attr_reader :bot, :text, :chat, :answers, :logger

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @answers = options[:answers]
    @logger = AppConfigurator.new.logger
  end

  def send
    if reply_markup
      bot.api.send_message(chat_id: chat.id, text: text, reply_markup: reply_markup)
    else
      bot.api.send_message(chat_id: chat.id, text: text)
    end

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  private

  def reply_markup
    return unless answers

    ReplyMarkupFormatter.new(answers).markup
  end
end
