//
//  ShoppingListSheetViewModel 2.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class ShoppingListSheetViewModel: ObservableObject {
    let listId: String
    
    @Published var items: [ShoppingListItemModel] = []
    @Published var selectedIDs: Set<String> = []
    @Published var isLoading = false
    @Published var isAdding = false
    @Published var errorMessage: String?
    
    private let manager = ShoppingListsManager.shared
    
    init(listId: String) {
        self.listId = listId
    }
    
    func loadItems() async {
        isLoading = true; defer { isLoading = false }
        
        do {
            let fetched = try await manager.getItems(listId: listId)
            items = fetched
            debugPrint("✅ [\(Self.self)] loadItems succeeded: \(fetched.count) items")
        } catch {
            debugPrint("❌ [\(Self.self)] loadItems error:", error)
            errorMessage = "Could not load items: \(error.localizedDescription)"
        }
    }
    
    func addItem(
        name: String,
        emoji: String,
        count: Int,
        price: Double,
        category: String?
    ) async {
        isAdding = true; defer { isAdding = false }
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            var newItem = ShoppingListItemModel(
                itemId: "",
                name: name,
                emoji: emoji,
                addedBy: auth.userId,
                price: price,
                numberOfTheItem: count,
                category: category,
                isBought: false,
                dateCreated: Date(),
                dateUpdated: nil
            )
            let newID = try await manager.addItem(item: newItem, listId: listId)
            newItem.itemId = newID
            items.append(newItem)
            debugPrint("✅ [\(Self.self)] addItem: \(newID)")
        } catch {
            debugPrint("❌ [\(Self.self)] addItem error:", error)
            errorMessage = "Add failed: \(error.localizedDescription)"
        }
    }
    
    func updateItem(
        id: String,
        emoji: String,
        name: String,
        count: Int,
        price: Double,
        category: String?,
        isBought: Bool
    ) async {
        do {
            let data: [String: Any] = [
                "emoji": emoji,
                "name": name,
                "number_of_items": count,
                "price": price,
                "category": category as Any,
                "is_bought": isBought,
                "date_updated": FieldValue.serverTimestamp()
            ]
            try await manager.updateItem(itemId: id, listId: listId, data: data)
            if let idx = items.firstIndex(where: { $0.id == id }) {
                items[idx].emoji = emoji
                items[idx].name = name
                items[idx].numberOfTheItem = count
                items[idx].price = price
                items[idx].category = category
                items[idx].isBought = isBought
                items[idx].dateUpdated = Date()
            }
            debugPrint("✅ [\(Self.self)] updateItem: \(id)")
        } catch {
            debugPrint("❌ [\(Self.self)] updateItem error:", error)
            errorMessage = "Update failed: \(error.localizedDescription)"
        }
    }
    
    func deleteSelected() async {
        let toDelete = Array(selectedIDs)
        for id in toDelete {
            do {
                try await manager.deleteItem(itemId: id, listId: listId)
                items.removeAll { $0.id == id }
                selectedIDs.remove(id)
                debugPrint("✅ [\(Self.self)] deleteItem: \(id)")
            } catch {
                debugPrint("❌ [\(Self.self)] deleteSelected error:", error)
                errorMessage = "Delete failed: \(error.localizedDescription)"
            }
        }
    }
}
