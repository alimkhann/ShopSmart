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
    @Published var validationError: String?
    
    var canCreate: Bool {
        !pendingName.isEmpty && pendingEmoji.count == 1
    }
    
    @MainActor
    func createList() async -> Bool {
        let name  = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let emoji = pendingEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            validationError = "Please enter a name for your shopping list."
            return false
        }
        guard emoji.count == 1 else {
            validationError = "Emoji must be exactly one character."
            return false
        }
        guard let auth = try? AuthenticationManager.shared.getAuthenticatedUser() else {
            validationError = "Authentication error. Please sign in again."
            return false
        }
        
        let newList = ShoppingListModel(
            name: name,
            emoji: emoji,
            ownerId: auth.userId,
            collaborators: [auth.userId]
        )
        
        isCreating = true
        defer { isCreating = false }
        
        do {
            try Firestore.firestore()
                .collection("lists")
                .addDocument(from: newList)
            
            pendingName = ""
            pendingEmoji = ""
            return true
        } catch {
            validationError = "Unable to create list: \(error.localizedDescription)"
            return false
        }
    }
}

