//
//  TestController.swift
//  
//
//  Created by hien.tran on 2/15/21.
//

import Foundation
import TelegramBotSDK

public class TestController {
    let bot: TelegramBot

    public init(bot: TelegramBot, router: inout Router) {
        self.bot = bot
        router["test", [.slashRequired, .caseSensitive]] = test
        router["✉️ Support"] = onSupport
    }

    public func test(context: Context) -> Bool {
        var startText = ""
        startText += "chatId: \(context.chatId)\n"
        startText += "command: \(context.command)\n"
        startText += "privateChat: \(context.privateChat)\n"
        startText += "properties: \(context.properties)\n"
        startText += "slash: \(context.slash)\n"
        startText += "args: \(context.args)\n"
        startText += "bot: \(context.bot)\n"
        startText += "fromId: \(context.fromId)\n"
        startText += "firstName: \(context.message?.contact?.firstName)\n"
        startText += "lastName: \(context.message?.contact?.lastName)\n"
        startText += "phone: \(context.message?.contact?.phoneNumber)\n"
        startText += "userID: \(context.message?.contact?.userId)\n"
        startText += "replyTo: \(context.message?.replyToMessage?.text)\n"
        startText += "replyToUser: \(context.message?.replyToMessage?.from?.username)\n"
        startText += "args.isAtEnd: \(context.args.isAtEnd)\n"
        startText += "args.scanRestOfString: \(context.args.scanRestOfString())\n"
        startText += "args.scanWords: \(context.args.scanWords())\n"
        startText += "args.scanWord: \(context.args.scanWord())\n"


//        context.respondAsync(startText)
        let replyTo = context.privateChat ? nil : context.message?.messageId

        let markup = ReplyKeyboardMarkup(
            keyboard: [
                [KeyboardButton(text: "➕ Add"), KeyboardButton(text: "🎁 List"), KeyboardButton(text: "⛔️ Delete")],
                [KeyboardButton(text: "ℹ️ Help"), KeyboardButton(text: "✉️ Support")],
            ],
            resizeKeyboard: true,
            oneTimeKeyboard: true,
            selective: replyTo != nil
        )

        context.respondAsync(
            startText,
            parseMode: .none,
            disableWebPagePreview: false,
            disableNotification: false,
            replyToMessageId: context.message?.messageId,
            replyMarkup: .replyKeyboardMarkup(markup),
            [:]
        ) { message, error in
            //
        }
        return true
    }

    func showMainMenu(context: Context, text: String) throws {
        // Use replies in group chats, otherwise bot won't be able to see the text typed by user.
        // In private chats don't clutter the chat with quoted replies.
        let replyTo = context.privateChat ? nil : context.message?.messageId

        let markup = ReplyKeyboardMarkup(
            keyboard: [
                [KeyboardButton(text: "➕ Add"), KeyboardButton(text: "🎁 List"), KeyboardButton(text: "⛔️ Delete")],
                [KeyboardButton(text: "ℹ️ Help"), KeyboardButton(text: "✉️ Support")],
            ],
            resizeKeyboard: true,
            oneTimeKeyboard: true,
            selective: replyTo != nil
        )
            //markup.one_time_keyboard = true
//            markup.resizeKeyboard = true
//            markup.selective = replyTo != nil
//            markup.keyboardStrings = [
//                [ Commands.add[0], Commands.list[0], Commands.delete[0] ],
//                [ Commands.help[0], Commands.support[0] ]
//            ]
        context.respondAsync(text, replyMarkup: .replyKeyboardMarkup(markup))
    }

    public func onSupport(context: Context) -> Bool {
        let button = InlineKeyboardButton(
            text:  "🌮",
            url: "https://telegram.me/zabiyaka_support"
        )

        let button2 = InlineKeyboardButton(text: "✅", url: "https://telegram.me/zabiyaka_support")

        let markup = InlineKeyboardMarkup(inlineKeyboard: [[button, button2]])

        context.respondAsync(
            "Please click the button below to join *Zabiyaka Support* group.",
            parseMode: ParseMode(rawValue: "markdown"),
            replyMarkup: .inlineKeyboardMarkup(markup)
        )

        return true
    }
}

