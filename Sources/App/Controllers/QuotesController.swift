//
//  QuotesController.swift
//  
//
//  Created by hien.tran on 2/14/21.
//

import Foundation
import TelegramBotSDK
import Vapor

public final class QuotesController {
//    let bot: TelegramBot
	let app: Application

    public init(bot: TelegramBot, app: Application, router: inout Router) {
//        self.bot = bot
		self.app = app
        router["save", .slashRequired] = save
        router[.callback_query(data: nil)] = onCallbackQuery
    }

    public func save(context: Context) -> Bool {
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

		print("🌮messageID: \(context.message?.messageId), message: \(context.message?.text), reply: \(context.message?.replyToMessage?.text)")

        let buttonSave = InlineKeyboardButton(text:  "💾 Save", callbackData: "save-quote message-id=\(replyToMessageID)")
        let buttonCancel = InlineKeyboardButton(text: "🙅🏻‍♂️ Cancel", callbackData: "cancelsave")
        let markup = InlineKeyboardMarkup(inlineKeyboard: [[buttonSave, buttonCancel]])

        context.respondAsync(
            "👆Lưu câu thính xịn này được thả bởi \(pickuplineCreator)?",
            parseMode: .markdown,
            replyToMessageId: replyToMessageID,
            replyMarkup: .inlineKeyboardMarkup(markup)
        ) { message, error in
            guard let error = error else { return }
            print("🌮error: \(error)")
        }

        return true
    }

    public func onCallbackQuery(context: Context) throws -> Bool {
        guard let callbackQuery = context.update.callbackQuery else { return false }
        guard let chatId = callbackQuery.message?.chat.id else { return false }
        guard let messageId = callbackQuery.message?.messageId else { return false }
        guard let data = callbackQuery.data else { return false }

//        print("🌮data: \(data)")
//		print("🌮🌮messageID: \(context.message?.messageId), message: \(context.message?.text), , reply: \(context.message?.replyToMessage?.text)")

		if SaveCommandValidator().checkIfValid(data) {
			try savePickupline(context: context)
//            try listUsers(context: context)
		}

        return true
    }

	private func savePickupline(context: Context) throws -> Bool {
		guard
			let pickuplineToSaved = context.message?.replyToMessage?.text,
			let replyToUserID = context.message?.replyToMessage?.from?.id
		else {
			// return error message
			return false
		}

		var headers = HTTPHeaders()
		headers.add(name: .contentType, value: "application/json")
		headers.add(name: .acceptEncoding, value: "gzip, deflate")
		headers.add(name: .accept, value: "*/*")

		app.client
			.get("https://ba-thing-api.herokuapp.com/api/users/telegram/\(replyToUserID)")
			.flatMapThrowing{ [weak self] res in
				let user = try res.content.decode(User.self)

                print("🌮error: \(user.id.uuidString)")

				self?.app.client
					.post("https://ba-thing-api.herokuapp.com/api/quotes", headers: headers) { req in
						try req.content.encode([
                            "short": "",
							"long": pickuplineToSaved,
                            "userID": "\(user.id.uuidString)"
						])
					}
					.map { response in
						// save successfully
						// edit message

						//		if let markup = itemListInlineKeyboardMarkup(context: context) {
						//
						//			bot.editMessageReplyMarkupAsync(chatId: .chat(chatId), messageId: messageId, replyMarkup: .inlineKeyboardMarkup(markup))
						//		}

                        context.respondAsync("save \(response)") { message, error in
							guard let error = error else { return }
							print("🌮error: \(error)")
						}
					}
					.whenFailure { error in
						print("🌮🌮There was an error saving the user: \(error)")
                        context.respondAsync(error.localizedDescription)
						// send error message to client
						// return true
					}
			}
			.whenFailure { error in
				print("🌮There was an error saving the user: \(error)")
                context.respondAsync(error.localizedDescription)
				// send error message to client
				// return true
			}

//		let req = Request(method: .post, uri: "http://some-endpoint")
//		req.formURLEncoded = Node(node: [
//			"email": "mymail@vapor.codes"
//		])
//
//		try drop.client.respond(to: req)
//
//		let headers = HTTPHeaders()

		
//		let body = HTTP

//		let body = HTTPBody(


//		let httpReq = HTTPRequest(
//			method: .POST,
//			url: URL(string: "/post")!,
//			headers: headers,
//			body: body)
//
//		let client = HTTPClient.connect(hostname: "httpbin.org", on: req)
//
//		let httpRes = client.flatMap(to: HTTPResponse.self) { client in
//			return client.send(httpReq)
//		}

//		if let markup = itemListInlineKeyboardMarkup(context: context) {
//
//			bot.editMessageReplyMarkupAsync(chatId: .chat(chatId), messageId: messageId, replyMarkup: .inlineKeyboardMarkup(markup))
//		}

//		context.respondAsync(
//			"Searching messageID: \(quoteToSaved)?"
//		) { message, error in
//			guard let error = error else { return }
//			print("🌮error: \(error)")
//		}

		return true
	}
}
