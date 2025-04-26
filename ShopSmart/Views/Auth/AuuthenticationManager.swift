//
//  AuuthenticationManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import Foundation
import FirebaseAuth

struct 

final class AuthenticaionManager {
    
    static let shared = AuthenticaionManager()
    private init() { }
    
    func createUser(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        authDataResult.user.
    }
}
