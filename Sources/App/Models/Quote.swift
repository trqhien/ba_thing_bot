//
//  Quote.swift
//  
//
//  Created by hien.tran on 2/28/21.
//

import Vapor

final class Quote: Content {
//    let user: User
    let id: UUID
    let short: String?
    let long: String
}
