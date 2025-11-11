//
//  ProfileView.swift
//  My Pokemon
//
//  Created by Lukman Hakim on 05/11/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var isLoggedOut: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Name:")
                            .font(.headline)
                        Spacer()
                        Text(username)
                            .font(.body)
                    }

                    HStack {
                        Text("Email:")
                            .font(.headline)
                        Spacer()
                        Text(email)
                            .font(.body)
                    }
                    
                    HStack {
                        Text("Phone:")
                            .font(.headline)
                        Spacer()
                        Text(phone)
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: logout) {
                    Text("Logout")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .onAppear(perform: loadUser)
            .fullScreenCover(isPresented: $isLoggedOut) {
                LoginView() // arahkan ke halaman login setelah logout
            }
        }
    }

    private func loadUser() {
        username = UserDefaults.standard.string(forKey: "currentUsername") ?? "Unknown"
        email = UserDefaults.standard.string(forKey: "currentEmail") ?? "-"
        phone = UserDefaults.standard.string(forKey: "currentPhone") ?? "-"
    }

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        UserDefaults.standard.removeObject(forKey: "currentEmail")
        UserDefaults.standard.removeObject(forKey: "currentPhone")
        isLoggedOut = true
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
