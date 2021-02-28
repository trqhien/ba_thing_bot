//
//  File.swift
//  
//
//  Created by hien.tran on 2/13/21.
//

import Foundation

struct SaveCommandValidator: RegexValidatorType {
    let command = "save-quote"
    let messageIDParam = "message-id"
    var quote: String!

    var regex: NSRegularExpression {
        let expression = "^\(command) \(messageIDParam)=[0-9]*$"
        return NSRegularExpression(expression)
    }

    func messageID(input: String) -> Int? {
        let messageIDRegex = NSRegularExpression("\(messageIDParam)=[0-9]*$")
        guard let matchString = messageIDRegex.matchesInString(in: input).first else { return nil }

        let messageID = matchString.replacingOccurrences(of: "\(messageIDParam)=", with: "")
        return Int(messageID)
    }

    func checkIfValid(_ input: String) -> Bool {
        switch validate(input) {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    func validate(_ input: String) -> ValidationResult {
        return regex.matches(input)
            ? .success(())
            : .failure(Error.invalidEmailFormat)
    }
}

extension SaveCommandValidator {
    enum Error: Swift.Error {
        case invalidEmailFormat
    }
}
