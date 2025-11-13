//
//  UserModel.swift
//  mypokemon
//
//  Created by Lukman Hakim on 12/11/25.
//

import Foundation

struct UserModel: Codable {
    let id: String
    var username: String
    var email: String
    var phone: String
    var passwordHash: String
}
