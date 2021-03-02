//
//  QuotesController.swift
//  
//
//  Created by hien.tran on 2/14/21.
//

import Foundation
import TelegramBotSDK
import Vapor

//let BASE_URL = "http://localhost:8080"
let BASE_URL = "https://ba-thing-api.herokuapp.com"

public final class QuotesController {
    let bot: TelegramBot
	let app: Application

    public init(bot: TelegramBot, app: Application, router: inout Router) {
        self.bot = bot
		self.app = app
        router["save", .slashRequired] = save
        router["search", .slashRequired] = search
        router[.callback_query(data: nil)] = onCallbackQuery
    }

    func save(context: Context) -> Bool {
        guard
            let replyToUserID = context.message?.replyToMessage?.from?.id,
            let replyToMessageID = context.message?.replyToMessage?.messageId,
            let pickuplineToBeSaved = context.message?.replyToMessage?.text,
            !pickuplineToBeSaved.isEmpty
        else {
            print("❌ Either replyToUserID, replyToMessageID, pickuplineToBeSaved is nil")
            return false
        }

        var pickuplineCreator = ""

        if let replyToUsername = context.message?.replyToMessage?.from?.username {
            pickuplineCreator = "@\(replyToUsername)"
        } else if let replyToUserFirstName = context.message?.replyToMessage?.from?.firstName {
            pickuplineCreator = "[\(replyToUserFirstName)](tg://user?id=\(replyToUserID))"
        }

        let buttonConfirm = InlineKeyboardButton(text:  "✅ Ok lưu nhóoooo", callbackData: "save-quote message-id=\(replyToMessageID)")
        let markup = InlineKeyboardMarkup(inlineKeyboard: [[buttonConfirm]])

        context.respondAsync(
            "👆Lưu câu thính xịn này được thả bởi \(pickuplineCreator)?",
            parseMode: .markdown,
            replyToMessageId: replyToMessageID,
            replyMarkup: .inlineKeyboardMarkup(markup)
        )

        return true
    }

    func search(context: Context) -> Bool {
        guard let searchTerm = context.args.scanWord() else {
            context.respondAsync(
                "Cú pháp sai òi, thiếu search term nhó `/search [SEARCH_TERM]`",
                parseMode: .html
            )
            return true
        }

        app.client
            .get("\(BASE_URL)/api/quotes/search") { req in
                try req.query.encode(["term": searchTerm])
            }
            .flatMapThrowing { res in
                let quotes = try res.content.decode([Quote].self)

                if quotes.isEmpty {
                    context.respondAsync("Không tìm thấy thính nào cả")
                } else {
                    let things = quotes
                        .map { $0.long }
                        .reduce("") { (result, quote) in
                        return result + "\n\n" + quote
                    }

                    context.respondAsync(
                        """
                        <b>Các câu thính có chữ "\(searchTerm)"</b>
                        \(things)
                        """,
                        parseMode: .html
                    )
                }
            }
            .whenFailure { error in
                context.respondAsync(error.localizedDescription)
            }

        return true
    }

    public func onCallbackQuery(context: Context) throws -> Bool {
        guard let callbackQuery = context.update.callbackQuery else { return false }
        guard let data = callbackQuery.data else { return false }

		if SaveCommandValidator().checkIfValid(data) {
			try savePickupline(context: context)
		}

        return true
    }

    @discardableResult
	private func savePickupline(context: Context) throws -> Bool {
		guard
			let pickuplineToSaved = context.message?.replyToMessage?.text,
			let replyToUserID = context.message?.replyToMessage?.from?.id,
            let replyToMessageID = context.message?.replyToMessage?.messageId,
            let chatId = context.message?.chat.id,
            let messageId = context.message?.messageId
		else {
			return false
		}

        bot.editMessageTextSync(
            chatId: .chat(chatId),
            messageId: messageId,
            text: "⏳ <b>Đang lưu đừng manh động</b>",
            parseMode: .html
        )

		var headers = HTTPHeaders()
		headers.add(name: .contentType, value: "application/json")
		headers.add(name: .acceptEncoding, value: "gzip, deflate")
		headers.add(name: .accept, value: "*/*")

		app.client
			.get("\(BASE_URL)/api/users/telegram/\(replyToUserID)")
			.flatMapThrowing{ [weak self] res in
				let user = try res.content.decode(User.self)

				self?.app.client
					.post("\(BASE_URL)/api/quotes", headers: headers) { req in
						try req.content.encode([
                            "short": "",
							"long": pickuplineToSaved,
                            "userID": "\(user.id.uuidString)"
						])
					}
					.flatMapThrowing { [weak self] response in
                        _ = try response.content.decode(Quote.self)

                        self?.bot.editMessageTextAsync(
                            chatId: .chat(chatId),
                            messageId: messageId,
                            text: "<b>Ahihi lưu òi nha 👏🎉</b>",
                            parseMode: .html
                        )
					}
					.whenFailure { error in
                        context.respondAsync(error.localizedDescription)
					}
			}
			.whenFailure { error in
                context.respondAsync(error.localizedDescription)
			}

		return true
	}
}
