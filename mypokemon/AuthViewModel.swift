//
//  AuthViewModel.swift
//  mypokemon
//
//  Created by Lukman Hakim on 12/11/25.
//

import Foundation
import RxSwift
import RxCocoa
import Combine

final class AuthViewModel: ObservableObject {
    private let disposeBag = DisposeBag()
    private let store = CouchbaseUserStore.shared

    // UI-bindable states
    @Published var currentUser: UserModel? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // publik observables (jika ingin Rx)
    let loggedIn = PublishSubject<UserModel?>()

    func register(username: String, email: String, phone: String, password: String) {
        isLoading = true
        errorMessage = nil

        store.saveUser(username: username, email: email, phone: phone, password: password)
            .subscribe { [weak self] event in
                switch event {
                case .success:
                    self?.isLoading = false
                    // optionally auto-login or inform UI
                    self?.errorMessage = nil
                case .failure(let err):
                    self?.isLoading = false
                    self?.errorMessage = err.localizedDescription
                }
            }
            .disposed(by: disposeBag)
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        store.fetchUser(email: email, password: password)
            .subscribe { [weak self] event in
                switch event {
                case .success(let user):
                    print("-> success")
//                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let user = user {
                            self?.currentUser = user
                            print("-> currentUser : ", self?.currentUser)
                            // persist minimal info
                            UserDefaults.standard.set(user.username, forKey: "currentUsername")
                            UserDefaults.standard.set(user.email, forKey: "currentEmail")
                            UserDefaults.standard.set(user.phone, forKey: "currentPhone")
                            self?.loggedIn.onNext(user)
                        } else {
                            print("-> get error")
                            self?.errorMessage = "Invalid username or password"
                        }
//                    }
                case .failure(let err):
                    print("-> failed")
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        self?.errorMessage = err.localizedDescription
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    func loadCurrentUserFromDefaults() {
        if let email = UserDefaults.standard.string(forKey: "currentEmail") {
            store.fetchUser(email: email)
                .subscribe { [weak self] event in
                    switch event {
                    case .success(let user):
                        DispatchQueue.main.async {
                            self?.currentUser = user
                        }
                    case .failure:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        UserDefaults.standard.removeObject(forKey: "currentEmail")
        UserDefaults.standard.removeObject(forKey: "currentPhone")
    }
}

