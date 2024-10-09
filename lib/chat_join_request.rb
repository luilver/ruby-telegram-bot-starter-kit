# frozen_string_literal: true

# Chat join request
class ChatJoinRequest
  attr_reader :chat, :bot, :logger, :user

  def initialize(options)
    @bot = options[:bot]
    @chat = options[:chat]
    @user = options[:user]
    @logger = options[:logger]
  end

  # TODO: Handle gracefully the following errors:
  # 1. Telegram API has returned the error. (ok: false, error_code: 400,
  # description: "Bad Request: not enough rights to manage chat join requests")
  # (Telegram::Bot::Exceptions::ResponseError)
  # 2. Telegram API has returned the error. (ok: false, error_code: 400,
  # description: "Bad Request: group chat was upgraded to a supergroup chat",
  # parameters: {"migrate_to_chat_id"=>-1002107916201})
  # 3. Telegram error: USER_ALREADY_PARTICIPANT\
  def respond
    bot.api.approve_chat_join_request(chat_id: chat.id, user_id: user.id)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    logger.debug "error: `@#{e.message}` occurred"
  end
end
