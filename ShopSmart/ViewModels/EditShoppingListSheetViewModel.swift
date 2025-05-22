//
//  EditShoppingListSheetViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class EditShoppingListSheetViewModel: ObservableObject {
    let listId: String
    @Published var pendingEmoji: String
    @Published var pendingName: String
    
    @Published var isUpdating = false
    @Published var errorMessage: String?
    
    private let manager = ShoppingListsManager.shared
    
    init(listId: String, currentName: String, currentEmoji: String) {
        self.listId = listId
        self.pendingName = currentName
        self.pendingEmoji = currentEmoji
    }
    
    var canUpdate: Bool {
        !pendingName.trimmingCharacters(in: .whitespaces).isEmpty &&
        pendingEmoji.count == 1 &&
        (pendingEmoji.first?.isEmoji ?? false)
    }
    
    func updateList() async -> Bool {
        let newName  = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let newEmoji = pendingEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard canUpdate else { return false }
        
        isUpdating = true
        defer { isUpdating = false }

        let data: [String:Any] = [
            "name"         : newName,
            "emoji"        : newEmoji,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        do {
            try await manager.updateList(listId: listId, data: data)
            debugPrint("✅ [\(Self.self)] Shopping list updated: \(listId)")
            return true
        } catch {
            debugPrint("❌ Failed to update shopping list: [\(Self.self)] error:", error)
            errorMessage = "Failed to update list: \(error.localizedDescription)"
            return false
        }
    }
}
