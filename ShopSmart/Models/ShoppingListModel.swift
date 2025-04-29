//
//  ShoppingListModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import Foundation
import FirebaseFirestore

struct ShoppingListModel: Codable {
    @DocumentID var listId: String?
    var name: String
    var emoji: String
    let ownerId: String
    var collaborators: [String]
    let inviteUrl: String?
    var isShared: Bool
    let dateCreated: Date?
    let dateUpdated: Date?
    var items: [ShoppingListItemModel]?
    var numberOfItems: Int
    
    init(
        name: String,
        emoji: String,
        ownerId: String,
        collaborators: [String],
        inviteUrl: String? = nil,
        isShared: Bool = false,
        dateCreated: Date = Date(),
        dateUpdated: Date? = nil,
        items: [ShoppingListItemModel]? = nil,
        numberOfItems: Int = 0
      ) {
        self.name = name
        self.emoji = emoji
        self.ownerId = ownerId
        self.collaborators = collaborators
        self.inviteUrl = inviteUrl
        self.isShared = isShared
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
        self.items = items
        self.numberOfItems = numberOfItems
      }
}
