//
//  CouchbaseUserStore.swift
//  mypokemon
//
//  Created by Lukman Hakim on 12/11/25.
//

import Foundation
import CouchbaseLiteSwift
import RxSwift
import CryptoKit

final class CouchbaseUserStore {
    static let shared = CouchbaseUserStore()
    private let database: Database?

    private init() {
        do {
            database = try Database(name: "userdb")
        } catch {
            print("❌ Couchbase DB open error: \(error)")
            database = nil
        }
    }

    // MARK: - Helper: hash password
    static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Create / Register
    // returns Single<Bool> true if saved
    func saveUser(username: String, email: String, phone: String, password: String) -> Single<Bool> {
        return Single.create { single in
            guard let db = self.database else {
                single(.failure(NSError(domain: "Couchbase", code: -1, userInfo: [NSLocalizedDescriptionKey: "DB not available"])))
                return Disposables.create()
            }

            let docId = email.lowercased()
            if db.document(withID: docId) != nil {
                single(.failure(NSError(domain: "Couchbase", code: 409, userInfo: [NSLocalizedDescriptionKey: "User already exists"])))
                return Disposables.create()
            }

            let doc = MutableDocument(id: docId)
            doc.setString(username, forKey: "username")
            doc.setString(email, forKey: "email")
            doc.setString(phone, forKey: "phone")
            doc.setString(CouchbaseUserStore.sha256(password), forKey: "passwordHash")

            do {
                try db.saveDocument(doc)
                print("-> register success")
                single(.success(true))
            } catch {
                print("-> register fail")
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    // MARK: - Fetch by username & password -> Single<UserModel?>
    func fetchUser(email: String, password: String) -> Single<UserModel?> {
        return Single.create { single in
            guard let db = self.database else {
                single(.failure(NSError(domain: "Couchbase", code: -1, userInfo: [NSLocalizedDescriptionKey: "DB not available"])))
                return Disposables.create()
            }

            let docId = email.lowercased()
            if let doc = db.document(withID: docId) {
                let storedHash = doc.string(forKey: "passwordHash") ?? ""
                let inputHash = CouchbaseUserStore.sha256(password)
                if storedHash == inputHash {
                    let user = UserModel(
                        id: docId,
                        username: doc.string(forKey: "username") ?? "",
                        email: doc.string(forKey: "email") ?? email,
                        phone: doc.string(forKey: "phone") ?? "",
                        passwordHash: storedHash
                    )
                    print("-> ", user)
                    single(.success(user))
                } else {
                    print("failed : wrong password")
                    single(.success(nil)) // wrong password
                }
            } else {
                print("failed : not found")
                single(.success(nil)) // not found
            }

            return Disposables.create()
        }
    }

    // MARK: - Fetch by username only
    func fetchUser(email: String) -> Single<UserModel?> {
        return Single.create { single in
            guard let db = self.database else {
                single(.failure(NSError(domain: "Couchbase", code: -1, userInfo: [NSLocalizedDescriptionKey: "DB not available"])))
                return Disposables.create()
            }
            let docId = email.lowercased()
            if let doc = db.document(withID: docId) {
                let user = UserModel(
                    id: docId,
                    username: doc.string(forKey: "username") ?? "",
                    email: doc.string(forKey: "email") ?? "",
                    phone: doc.string(forKey: "phone") ?? "",
                    passwordHash: doc.string(forKey: "passwordHash") ?? ""
                )
                single(.success(user))
            } else {
                single(.success(nil))
            }
            return Disposables.create()
        }
    }

    // MARK: - Update fields (email / password)
    func updateUser(username: String, email: String?, phone: String?, newPassword: String?) -> Single<Bool> {
        return Single.create { single in
            guard let db = self.database else {
                single(.failure(NSError(domain: "Couchbase", code: -1, userInfo: [NSLocalizedDescriptionKey: "DB not available"])))
                return Disposables.create()
            }

            let docId = username.lowercased()
            guard let doc = db.document(withID: docId)?.toMutable() else {
                single(.failure(NSError(domain: "Couchbase", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return Disposables.create()
            }

            if let email = email {
                doc.setString(email, forKey: "email")
            }
            if let phone = phone {
                doc.setString(phone, forKey: "phone")
            }
            if let np = newPassword {
                doc.setString(CouchbaseUserStore.sha256(np), forKey: "passwordHash")
            }

            do {
                try db.saveDocument(doc)
                single(.success(true))
            } catch {
                single(.failure(error))
            }

            return Disposables.create()
        }
    }

    // MARK: - Delete user
    func deleteUser(email: String) -> Single<Bool> {
        return Single.create { single in
            guard let db = self.database else {
                single(.failure(NSError(domain: "Couchbase", code: -1, userInfo: [NSLocalizedDescriptionKey: "DB not available"])))
                return Disposables.create()
            }

            let docId = email.lowercased()
            if let doc = db.document(withID: docId) {
                do {
                    try db.deleteDocument(doc)
                    single(.success(true))
                } catch {
                    single(.failure(error))
                }
            } else {
                single(.success(false))
            }

            return Disposables.create()
        }
    }
}

