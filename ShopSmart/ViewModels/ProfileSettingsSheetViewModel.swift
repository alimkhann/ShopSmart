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
    @AppStorage("cachedUsername") private var cachedUsername: String = ""
    @Published var isUpdating = false
    @Published var isUploadingImage = false
    @Published var pendingImageData: Data? = nil
    @Published var pendingUsername: String? = nil
    @Published var errorMessage: String?
    let storageManager = StorageManager.shared
    let userManager = UserManager.shared
    
    var canSaveAll: Bool {
        let nameChanged = pendingUsername != nil && pendingUsername != user?.username
        let imageChanged = pendingImageData != nil
        return !isUpdating && !isUploadingImage && (nameChanged || imageChanged)
    }
    
    func loadCurrentUser() async {
        do {
            pendingUsername = cachedUsername
            
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: auth.userId)
            self.pendingUsername = cachedUsername
            debugPrint("✅ [\(Self.self)] User loaded: \(auth.userId)")
        } catch {
            debugPrint("❌ Profile image deletion failed: [\(Self.self)] error:", error)
            errorMessage = "Failed to delete profile image: \(error.localizedDescription)."
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
            debugPrint("✅ [\(Self.self)] Image picked.")
        } catch {
            debugPrint("❌ Image selection failed: [\(Self.self)] error:", error)
            errorMessage = "Image selection failed: \(error.localizedDescription)."
        }
    }
    
    func saveAllChanges() async {
        // 1) delete old image if replacing
        if let user = user,
           let oldPath = user.profileImagePath {
            do {
                try await StorageManager.shared.deleteImage(path: oldPath)
                debugPrint("✅ [\(Self.self)] Old profile image deleted.")
            } catch {
                debugPrint("❌ Old profile image deletion failed: [\(Self.self)] error:", error)
                errorMessage = "Failed to delete old profile image: \(error.localizedDescription)."
            }
        }
        
        // 2) upload new image
        if let data = pendingImageData, let user = user {
            isUploadingImage = true; defer { isUploadingImage = false }
            do {
                let (path, _) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
                let url = try await StorageManager.shared.getUrlForImage(path: path)
                try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
                debugPrint("✅ [\(Self.self)] New profile image uploaded.")
            } catch {
                debugPrint("❌ New profile image upload failed: [\(Self.self)] error:", error)
                errorMessage = "Failed to upload new profile image: \(error.localizedDescription)."
            }
            pendingImageData = nil
        }
        
        // 3) update username
        if let newName = pendingUsername, let user = user {
            isUpdating = true; defer { isUpdating = false }
            do {
                try await UserManager.shared.updateUsername(userId: user.userId, username: newName)
                cachedUsername = newName
                debugPrint("✅ [\(Self.self)] Username updated.")
            } catch {
                debugPrint("❌ Username update failed: [\(Self.self)] error:", error)
                errorMessage = "Failed to update username: \(error.localizedDescription)."
            }
            pendingUsername = nil
        }
        
        // 4) reload user
        if let user = user {
            do {
                self.user = try await UserManager.shared.getUser(userId: user.userId)
                self.pendingUsername = self.user?.username
                debugPrint("✅ [\(Self.self)] User reloaded.")
            } catch {
                debugPrint("❌ User reload failed: [\(Self.self)] error:", error)
                errorMessage = "Failed to reload user: \(error.localizedDescription)."
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
            debugPrint("✅ Profile image deleted: [\(Self.self)]")
        } catch {
            debugPrint("❌ Profile image deletion failed: [\(Self.self)] error:", error)
            errorMessage = "Failed to delete profile image: \(error.localizedDescription)."
        }
    }
    
    func logOut() throws {
        guard let user = user, let _ = user.profileImagePath else { return }
        
        if user.username != nil {
            UserDefaults.standard.removeObject(forKey: "cachedUsername")
        }
        
        try AuthenticationManager.shared.signOut()
        debugPrint("✅ Logged out: [\(Self.self)]")
    }
    
    func deleteAccount() async throws {
        guard let user = user else { throw URLError(.badServerResponse) }
        
        if let path = user.profileImagePath {
            try await StorageManager.shared.deleteImage(path: path)
        }
        
        if user.username != nil {
            UserDefaults.standard.removeObject(forKey: "cachedUsername")
        }
        
        let lists = try await ShoppingListsManager.shared.getLists(for: user.userId)
        
        for list in lists {
            guard let listId = list.listId else { continue }
            
            let items = try await ShoppingListsManager.shared.getItems(listId: listId)
            
            for item in items {
                guard let itemId = item.itemId else { continue }
                try await ShoppingListsManager.shared.deleteItem(itemId: itemId, listId: listId)
            }
            
            try await ShoppingListsManager.shared.deleteList(listId: listId)
        }
        
        try await UserManager.shared.deleteUser(userId: user.userId)
        try await AuthenticationManager.shared.deleteAccount()
        debugPrint("✅ [\(Self.self)] Account deleted.")
    }
}

