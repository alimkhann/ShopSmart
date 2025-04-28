//
//  UserManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import Foundation
import FirebaseFirestore

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: UserModel) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await userDocument(userId: userId).getDocument(as: UserModel.self, decoder: decoder)
    }
    
    func updateUserProfileImagePath(userId: String, path: String?, url: String?) async throws {
        let data: [String:Any] = [
            "profile_image_path" : path as Any,
            "profile_image_path_url" : url as Any,
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateUsername(userId: String, username: String) async throws {
        let data: [String: Any] = [
            "username" : username,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func deleteUser(userId: String) async throws {
        try await userDocument(userId: userId).delete()
    }
}
