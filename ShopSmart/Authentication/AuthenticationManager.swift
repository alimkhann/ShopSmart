//
//  AuuthenticationManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import Foundation
import FirebaseAuth

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    @discardableResult
    func signUp(username: String, email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult  = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let changeRequest = authDataResult.user.createProfileChangeRequest()
        changeRequest.displayName = username
        try await changeRequest.commitChanges()
        
        let model = AuthDataResultModel(user: authDataResult.user)
        let user = UserModel(auth: model)
        try await UserManager.shared.createNewUser(user: user)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.delete()
    }
}
