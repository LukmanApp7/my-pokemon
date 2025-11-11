//
//  SQLiteManager.swift
//  mypokemon
//
//  Created by Lukman Hakim on 11/11/25.
//

import Foundation
import SQLite3

struct User {
    let id: Int
    let name: String
    let email: String
    let phone: String
}

class SQLiteManager {
    static let shared = SQLiteManager()
    private let dbName = "UserDatabase.sqlite"
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createTableIfNeeded()
    }
    
    // MARK: - Open Database
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(dbName)
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("❌ Error opening database.")
        } else {
            print("✅ Database opened at \(fileURL.path)")
        }
    }
    
    // MARK: - Create Table
    private func createTableIfNeeded() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            phone TEXT NOT NULL
        );
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Table created or already exists.")
            } else {
                print("❌ Could not create table.")
            }
        } else {
            print("❌ Create table statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    func fetchUser(email: String, password: String) -> User? {
        let query = "SELECT id, name, email, phone FROM users WHERE email = ? AND password = ? LIMIT 1;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) != SQLITE_OK {
            return nil
        }

        sqlite3_bind_text(stmt, 1, (email as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (password as NSString).utf8String, -1, nil)

        var user: User?

        if sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let email = String(cString: sqlite3_column_text(stmt, 2))
            let phone = String(cString: sqlite3_column_text(stmt, 3))
            user = User(id: id, name: name, email: email, phone: phone)
        }

        sqlite3_finalize(stmt)
        return user
    }
    
    // MARK: - Execute Statement
    func execute(query: String, parameters: [String]? = nil) -> Bool {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing statement.")
            return false
        }
        
        if let params = parameters {
            for (index, value) in params.enumerated() {
                sqlite3_bind_text(statement, Int32(index + 1), (value as NSString).utf8String, -1, nil)
            }
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            sqlite3_finalize(statement)
            return true
        } else {
            print("❌ Error executing query: \(query)")
            sqlite3_finalize(statement)
            return false
        }
    }
    
    // MARK: - Query
    func query(_ query: String, parameters: [String]? = nil) -> [[String: Any]] {
        var result: [[String: Any]] = []
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparing query.")
            return []
        }
        
        if let params = parameters {
            for (index, value) in params.enumerated() {
                sqlite3_bind_text(statement, Int32(index + 1), (value as NSString).utf8String, -1, nil)
            }
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [String: Any] = [:]
            for i in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, i))
                let value = sqlite3_column_text(statement, i)
                row[name] = value != nil ? String(cString: value!) : nil
            }
            result.append(row)
        }
        
        sqlite3_finalize(statement)
        return result
    }
}

