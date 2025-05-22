//
//  CreateShoppingListSheetViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class CreateShoppingListSheetViewModel: ObservableObject {
    @Published private(set) var list: ShoppingListModel? = nil
    @Published var pendingEmoji = ""
    @Published var pendingName = ""
    @Published var isCreating = false
    @Published var errorMessage: String?
    let shoppingListsManager = ShoppingListsManager.shared
    let authManager = AuthenticationManager.shared
    
    var canCreate: Bool {
        !pendingName.isEmpty &&
        pendingEmoji.count == 1 &&
        (pendingEmoji.first?.isEmoji ?? false)
    }
    
    @MainActor
    func createList() async -> Bool {
        let name  = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let emoji = pendingEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard canCreate else { return false }
        
        guard let auth = try? authManager.getAuthenticatedUser() else { return false }
        
        let newList = ShoppingListModel(
            name: name,
            emoji: emoji,
            ownerId: auth.userId,
            collaborators: [auth.userId]
        )
        
        isCreating = true
        defer { isCreating = false }
        
        do {
            _ = try await shoppingListsManager.createList(list: newList)
            debugPrint("✅ [\(Self.self)] Shopping list created: \(newList.name)")
            
            pendingName = ""
            pendingEmoji = ""
            return true
        } catch {
            debugPrint("❌ Failed to create shopping list: [\(Self.self)] error:", error)
            errorMessage = "Failed to create list: \(error.localizedDescription)"
            return false
        }
    }
}
