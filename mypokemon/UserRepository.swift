//
//  UserRepository.swift
//  mypokemon
//
//  Created by Lukman Hakim on 11/11/25.
//

import Foundation

class UserRepository {
    private let db = SQLiteManager.shared
    
    func register(email: String, password: String, name: String, phone: String) throws {
        // Cek apakah email sudah ada
        let checkQuery = "SELECT * FROM users WHERE email = ?"
        let existing = db.query(checkQuery, parameters: [email])
        guard existing.isEmpty else {
            throw RegistrationError.emailExists
        }
        
        let insertQuery = "INSERT INTO users (email, password, name, phone) VALUES (?, ?, ?, ?)"
        let success = db.execute(query: insertQuery, parameters: [email, password, name, phone])
        if !success {
            throw RegistrationError.insertFailed
        }
    }
    
    func login(email: String, password: String) -> Bool {
        let query = "SELECT * FROM users WHERE email = ? AND password = ?"
        let result = db.query(query, parameters: [email, password])
        if !result.isEmpty {
            if let user = SQLiteManager.shared.fetchUser(email: email, password: password) {
                UserDefaults.standard.set(user.name, forKey: "currentUsername")
                UserDefaults.standard.set(user.email, forKey: "currentEmail")
                return true
            }
        }
        return !result.isEmpty
    }
    
    enum RegistrationError: LocalizedError {
        case emailExists
        case insertFailed
        
        var errorDescription: String? {
            switch self {
            case .emailExists: return "Email sudah terdaftar."
            case .insertFailed: return "Gagal menyimpan data."
            }
        }
    }
}
