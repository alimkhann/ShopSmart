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
    
    func createList(list: ShoppingListModel) throws -> String {
        let ref = try listCollection.addDocument(from: list)
          return ref.documentID
    }
    
    func getList(listId: String) async throws -> ShoppingListModel {
        try await listDocument(listId: listId).getDocument(as: ShoppingListModel.self, decoder: decoder)
    }
    
    func getLists(for userId: String) async throws -> [ShoppingListModel] {
        let snapshot = try await listCollection
          .whereField("collaborators", arrayContains: userId)
          .getDocuments()
        return try snapshot.documents.map {
          try $0.data(as: ShoppingListModel.self, decoder: decoder)
        }
      }
    
    func updateList(listId: String, data: [String: Any]) async throws {
        try await listDocument(listId: listId).updateData(data)
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
    }
    
    // MARK: Item CRUD
    
    func addItem(item: ShoppingListItemModel, listId: String) async throws {
        try itemCollection(listId: listId)
              .document(item.itemId)
              .setData(from: item, merge: false, encoder: encoder)
    }
    
    func getItems(listId: String) async throws -> [ShoppingListItemModel] {
        let snapshot = try await itemCollection(listId: listId).getDocuments()
        return try snapshot.documents.map { doc in
            try doc.data(as: ShoppingListItemModel.self, decoder: decoder)
        }
    }
    
    func updateItem(itemId: String, listId: String, data: [String: Any]) async throws {
        try await listDocument(listId: listId).collection("items").document(itemId).updateData(data)
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
    
    func updateItemNumberOfItems(itemId: String, listId: String, newNumberOfItems: Int) async throws {
        let data : [String: Any] = [
            "number_of_items" : newNumberOfItems,
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
        try await listDocument(listId: listId).collection("items").document(itemId).delete()
    }
}
