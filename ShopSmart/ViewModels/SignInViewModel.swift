//
//  SignInViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import Foundation

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSigningIn = false
    
    func signIn() async throws {
        guard !isSigningIn else { return }
        
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "Validation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Email and password required"])
        }
        
        isSigningIn = true
        defer { isSigningIn = false }
        
        try await AuthenticationManager.shared.signIn(email: email, password: password)
    }
}

