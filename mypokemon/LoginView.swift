//
//  LoginView.swift
//  mypokemon
//
//  Created by Lukman Hakim on 06/11/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var loginError: String?
    @State private var isLoggedIn = false
    private let repo = UserRepository()

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                // iOS 16 ke atas
                NavigationStack {
                    loginContent
                }
            } else {
                // iOS 14–15 fallback
                NavigationView {
                    loginContent
                        .navigationBarHidden(true) // hide default bar
                }
                .navigationViewStyle(StackNavigationViewStyle()) // untuk iPad fix
            }
        }
    }

    private var loginContent: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [.green.opacity(0.7), .blue.opacity(0.7)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo
                Image(systemName: "lock.shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 20)

                // Title
                Text("My Pokemon")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                // Form Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3)))

                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                        } else {
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                        }

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.3)))
                }
                .padding(.horizontal, 32)

                // Error Message
                if let error = loginError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                        .padding(.top, -8)
                }

                // Login Button
                Button(action: login) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }
                .disabled(isLoading)
                .padding(.horizontal, 32)
                .padding(.top, 10)

                HStack {
                    Text("Belum punya akun?")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.9))
                    NavigationLink(destination: RegistrationView()) {
                        Text("Daftar di sini")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                            .underline()
                    }
                }
                .padding(.top, 10)
                
                Spacer()

                // Footer
                Text("© 2025 Daarul Lathiif Labs")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom)
            }

            // Navigation ke halaman berikut
            NavigationLink(destination: LandingView(), isActive: $isLoggedIn) {
                EmptyView()
            }
            .hidden()
        }
    }

    func login() {
        loginError = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Please enter both email and password."
            return
        }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            
//            if email.lowercased() == "test" && password == "123456" {
//                print("✅ Login success")
//                withAnimation {
//                    isLoggedIn = true
//                }
//            } else {
//                loginError = "Invalid email or password."
//            }
            
            if repo.login(email: email, password: password) {
                loginError = nil
                isLoggedIn = true
            } else {
                loginError = "Email atau password salah."
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
