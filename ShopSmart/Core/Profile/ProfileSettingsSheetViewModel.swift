//
//  ProfileSettingsSheetViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 27/4/2025.
//

import SwiftUI
import PhotosUI

@MainActor
final class ProfileSettingsSheetViewModel: ObservableObject {
    @Published private(set) var user: UserModel? = nil
    @Published var isUpdating = false
    @Published var isUploadingImage = false
    @Published var pendingImageData: Data? = nil
    @Published var pendingUsername: String? = nil

    var canSaveAll: Bool {
        let nameChanged = pendingUsername != nil && pendingUsername != user?.username
        let imageChanged = pendingImageData != nil
        return !isUpdating && !isUploadingImage && (nameChanged || imageChanged)
    }

    func loadCurrentUser() async {
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: auth.userId)
            self.pendingUsername = user?.username
        } catch {
            print("Load user failed: \(error)")
        }
    }

    func imagePicked(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let compressed: Data
            if let uiImage = UIImage(data: data)?.resized(toMaxDimension: 800),
               let jpeg = uiImage.jpegData(compressionQuality: 0.5) {
                compressed = jpeg
            } else {
                compressed = data
            }
            pendingImageData = compressed
        } catch {
            print("Image load failed: \(error)")
        }
    }

    func saveAllChanges() async {
        // 1) delete old image if replacing
        if let user = user,
           let oldPath = user.profileImagePath {
            do {
                try await StorageManager.shared.deleteImage(path: oldPath)
            } catch {
                print("Failed deleting old image: \(error)")
            }
        }
        
        // 2) upload new image
        if let data = pendingImageData, let user = user {
            isUploadingImage = true; defer { isUploadingImage = false }
            do {
                let (path, _) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
                let url = try await StorageManager.shared.getUrlForImage(path: path)
                try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
            } catch {
                print("Upload failed: \(error)")
            }
            pendingImageData = nil
        }
        
        // 3) update username
        if let newName = pendingUsername, let user = user {
            isUpdating = true; defer { isUpdating = false }
            do {
                try await UserManager.shared.updateUsername(userId: user.userId, username: newName)
            } catch {
                print("Username update failed: \(error)")
            }
            pendingUsername = nil
        }
        
        // 4) reload user
        if let user = user {
            do {
                self.user = try await UserManager.shared.getUser(userId: user.userId)
                self.pendingUsername = self.user?.username
            } catch {
                print("Reload user failed: \(error)")
            }
        }
    }

    func deleteProfileImage() async {
        guard let user = user, let path = user.profileImagePath else { return }
        do {
            try await StorageManager.shared.deleteImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            self.pendingImageData = nil
        } catch {
            print("Delete failed: \(error)")
        }
    }

    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }

    func deleteAccount() async throws {
        guard let user = user else { throw URLError(.badServerResponse) }
        // delete profile image from storage
        if let path = user.profileImagePath {
            try await StorageManager.shared.deleteImage(path: path)
        }
        try await UserManager.shared.deleteUser(userId: user.userId)
        try await AuthenticationManager.shared.deleteAccount()
    }
}

