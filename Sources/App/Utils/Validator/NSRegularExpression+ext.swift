//
//  NSRegularExpression.swift
//  
//
//  Created by hien.tran on 2/13/21.
//

import Foundation

extension NSRegularExpression {

    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Invalid Refular Expression: \(pattern)")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

    func matchesInString(in text: String) -> [String] {
        let results = matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results.map { String(text[Range($0.range, in: text)!]) }
    }
}
