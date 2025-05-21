//
//  ShoppingListManager.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import Foundation
import FirebaseFirestore

final class ShoppingListsManager {
    
    static let shared = ShoppingListsManager()
    private init() {}
    
    private let listCollection = Firestore.firestore().collection("lists")
    
    private func listDocument(listId: String) -> DocumentReference {
        listCollection.document(listId)
    }
    
    private func itemCollection(listId: String) -> CollectionReference {
        listDocument(listId: listId).collection("items")
    }
    
    private func itemDocument(listId: String, itemId: String) -> DocumentReference {
        itemCollection(listId: listId).document(itemId)
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
    
    // MARK: List CRUD
    
    func createList(list: ShoppingListModel) async throws -> String {
        let docRef = try listCollection.addDocument(from: list, encoder: encoder)
        let newID = docRef.documentID
        debugPrint("✅ [\(Self.self)] createList succeeded, new ID: \(newID)")
        return newID
    }
    
    func getListId(from list: ShoppingListModel) throws -> String {
        guard let id = list.listId else {
            debugPrint("❌ [\(Self.self)] getListId failed: listId is nil")
            throw URLError(.badURL)
        }
        debugPrint("✅ [\(Self.self)] getListId: \(id)")
        return id
    }
    
    func getList(listId: String) async throws -> ShoppingListModel {
        let model = try await listDocument(listId: listId)
            .getDocument(as: ShoppingListModel.self, decoder: decoder)
        debugPrint("✅ [\(Self.self)] getList succeeded: \(listId)")
        return model
    }
    
    func getLists(for userId: String) async throws -> [ShoppingListModel] {
        let snapshot = try await listCollection
            .whereField("collaborators", arrayContains: userId)
            .getDocuments()
        let lists = try snapshot.documents.map {
            try $0.data(as: ShoppingListModel.self, decoder: decoder)
        }
        debugPrint("✅ [\(Self.self)] getLists succeeded: \(lists.count) lists for user \(userId)")
        return lists
    }
    
    func updateList(listId: String, data: [String: Any]) async throws {
        try await listDocument(listId: listId).updateData(data)
        debugPrint("✅ [\(Self.self)] updateList succeeded: \(listId)")
    }
    
    func updateListName(listId: String, newName: String) async throws {
        let data: [String:Any] = [
            "name" : newName,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateList(listId: listId, data: data)
    }
    
    func updateListEmoji(listId: String, newEmoji: String) async throws {
        let data: [String: Any] = [
            "emoji" : newEmoji,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        try await updateList(listId: listId, data: data)
    }
    
    func updateListCollaborators(listId: String, newCollaborators: [String]) async throws {
        let data: [String: Any] = [
            "collaborators" : newCollaborators,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateList(listId: listId, data: data)
    }
    
    func updateIsShared(listId: String, isShared: Bool) async throws {
        let data: [String: Any] = [
            "is_shared" : isShared,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateList(listId: listId, data: data)
    }
    
    func updateNumberOfItems(listId: String, newNumberOfItems: Int) async throws {
        let data: [String: Any] = [
            "number_of_items" : newNumberOfItems,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateList(listId: listId, data: data)
    }
    
    func deleteList(listId: String) async throws {
        try await listDocument(listId: listId).delete()
        debugPrint("✅ [\(Self.self)] deleteList succeeded: \(listId)")
    }
    
    // MARK: Item CRUD
    
    func addItem(item: ShoppingListItemModel, listId: String) async throws -> String {
        let colRef = itemCollection(listId: listId)
        let newDoc = colRef.document()
        var withID = item
        withID.itemId = newDoc.documentID
        try newDoc.setData(from: withID, encoder: encoder)
        debugPrint("✅ [\(Self.self)] addItem succeeded: \(String(describing: withID.itemId)) to list \(listId)")
        
        let count = try await getNumberOfItems(listId: listId)
        try await updateNumberOfItems(listId: listId, newNumberOfItems: count + 1)
        
        guard let itemId = withID.itemId else {
            debugPrint("❌ [\(Self.self)] addItem missing itemId after write")
            throw URLError(.unknown)
        }
        
        return itemId
    }
    
    func getItems(listId: String) async throws -> [ShoppingListItemModel] {
        let snapshot = try await itemCollection(listId: listId).getDocuments()
        let items = try snapshot.documents.map {
            try $0.data(as: ShoppingListItemModel.self, decoder: decoder)
        }
        debugPrint("✅ [\(Self.self)] getItems succeeded: \(items.count) for list \(listId)")
        return items
    }
    
    func getNumberOfItems(listId: String) async throws -> Int {
        let count = try await getItems(listId: listId).count
        debugPrint("✅ [\(Self.self)] getNumberOfItems: \(count) for list \(listId)")
        return count
    }
    
    func updateItem(itemId: String, listId: String, data: [String: Any]) async throws {
        try await itemCollection(listId: listId).document(itemId).updateData(data)
        debugPrint("✅ [\(Self.self)] updateItem succeeded: \(itemId) in list \(listId)")
    }
    
    func updateItemName(itemId: String, listId: String, newName: String) async throws {
        let data : [String: Any] = [
            "name" : newName,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemEmoji(itemId: String, listId: String, newEmoji: String) async throws {
        let data : [String: Any] = [
            "emoji" : newEmoji,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemAddedBy(itemId: String, listId: String, newAddedBy: String) async throws {
        let data : [String: Any] = [
            "added_by" : newAddedBy,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemPrice(itemId: String, listId: String, newPrice: Double) async throws {
        let data : [String: Any] = [
            "price" : newPrice,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemNumberOfTheItem(itemId: String, listId: String, newNumberOfTheItem: Int) async throws {
        let data : [String: Any] = [
            "number_of_the_item" : newNumberOfTheItem,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemCategory(itemId: String, listId: String, newCategory: String) async throws {
        let data : [String: Any] = [
            "category" : newCategory,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemIsBought(itemId: String, listId: String, isBought: Bool) async throws {
        let data : [String: Any] = [
            "is_bought" : isBought,
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func updateItemUrlLink(itemId: String, listId: String, newUrlLink: String?) async throws {
        let data : [String: Any] = [
            "url_link" : newUrlLink ?? NSNull(),
            "date_updated" : FieldValue.serverTimestamp()
        ]
        
        try await updateItem(itemId: itemId, listId: listId, data: data)
    }
    
    func deleteItem(itemId: String, listId: String) async throws {
        try await itemCollection(listId: listId).document(itemId).delete()
        debugPrint("✅ [\(Self.self)] deleteItem succeeded: \(itemId) from list \(listId)")
        
        let count = try await getNumberOfItems(listId: listId)
        try await updateNumberOfItems(listId: listId, newNumberOfItems: count - 1)
    }
}
