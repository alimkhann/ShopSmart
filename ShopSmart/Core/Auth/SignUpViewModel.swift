//
//  SignInViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import SwiftUI

@MainActor
final class SignUpViewModel: ObservableObject {
    @AppStorage("cachedUsername") private var cachedUsername: String = ""
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isSigningUp = false
    
    func signUp() async throws {
        guard !isSigningUp else { return }
        
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Validation", code: 0, userInfo: [NSLocalizedDescriptionKey: "All fields are required"])
        }
        
        isSigningUp = true
        defer { isSigningUp = false }
        
        let authDataResult = try await AuthenticationManager.shared.signUp(
            username: username,
            email: email,
            password: password
        )
        let user = UserModel(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        
        cachedUsername = username
    }
}
