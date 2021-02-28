//
//  User.swift
//  
//
//  Created by hien.tran on 2/3/21.
//

import Vapor

final class User: Content {
    let id: UUID
    let telegramID: Int
    let firstName: String
    let lastName: String?
    let username: String?
}
