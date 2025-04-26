//
//  ProfileManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import Foundation
import FirebaseAuth
import PhotosUI

final class ProfileManager {
    static let shared = ProfileManager()
    private init() {}

    func updateUsername(to newName: String) async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newName
        try await changeRequest.commitChanges()
    }

    func updateProfileImage(_ imageData: Data) async throws {
        let urlString = try await StorageManager.shared.uploadProfileImage(data: imageData)
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = URL(string: urlString)
        try await changeRequest.commitChanges()
    }

    func deleteProfileImage() async throws {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = nil
        try await changeRequest.commitChanges()
    }
}
