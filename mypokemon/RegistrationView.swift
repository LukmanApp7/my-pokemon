//
//  RegistrationView.swift
//  mypokemon
//
//  Created by Lukman Hakim on 11/11/25.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var message = ""
    @State private var showAlert = false
    private let repo = UserRepository()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Registrasi")
                .font(.title)
                .bold()
            
            TextField("Name", text: $name)
                .keyboardType(.default)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            
            HStack {
                if showPassword {
                    TextField("Password", text: $password)
                        .textContentType(.oneTimeCode)
                        .disableAutocorrection(true)
                } else {
                    SecureField("Password", text: $password)
                        .textContentType(.oneTimeCode)
                        .disableAutocorrection(true)
                }

                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            HStack {
                if showConfirmPassword {
                    TextField("Confirm Password", text: $confirmPassword)
                        .textContentType(.oneTimeCode)
                        .disableAutocorrection(true)
                } else {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.oneTimeCode)
                        .disableAutocorrection(true)
                }

                Button(action: { showConfirmPassword.toggle() }) {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if let msg = message {
                Text(msg)
                    .foregroundColor(msg.contains("berhasil") ? .green : .red)
                    .font(.footnote)
            }
            
            Button("Daftar") {
                register()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
    
    private func register() {
        guard !email.isEmpty, !password.isEmpty else {
            message = "Email dan password wajib diisi."
            return
        }
        guard password == confirmPassword else {
            message = "Password tidak cocok."
            return
        }
        do {
            try repo.register(email: email, password: password, name: name, phone: phone)
            message = "Registrasi berhasil! Silakan login."
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            message = error.localizedDescription
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
