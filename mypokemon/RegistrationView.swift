//
//  RegistrationView.swift
//  mypokemon
//
//  Created by Lukman Hakim on 11/11/25.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var vm = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var message: String?
    @State private var showAlert = false
//    private let repo = UserRepository()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Registration")
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
            
            if let msg = message{
                Text(msg)
                    .foregroundColor(msg.contains("berhasil") ? .green : .red)
                    .font(.footnote)
            }
            
            Button(action: {
                register()
            }) {
                Text(showAlert ? "Registering..." : "Register")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding()
    }
    
    private func register() {
        guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
            message = "Please fill all fields"
            return
        }
        guard password == confirmPassword else {
            message = "Passwords do not match"
            return
        }
        showAlert = true
        vm.register(username: name, email: email, phone: phone, password: password)
        showAlert = vm.isLoading
        print("-> error message : ", vm.errorMessage)
        if vm.errorMessage == nil {
            message = "Registrasi berhasil! Silakan login."
        } else {
            message = vm.errorMessage
        }
        print("-> message", message)
        // observe registration result by checking vm.errorMessage or navigate back after small delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
