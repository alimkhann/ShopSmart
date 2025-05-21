//
//  ShoppingListItemModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 29/4/2025.
//

import Foundation
import FirebaseFirestore

struct ShoppingListItemModel: Codable, Identifiable, Equatable {
    @DocumentID var itemId: String?
    var name: String
    var emoji: String
    var addedBy: String
    var price: Double
    var numberOfTheItem: Int
    var category: String?
    var isBought: Bool = false
    let dateCreated: Date?
    var dateUpdated: Date?
    
    var id: String {
        guard let itemId = itemId else {
            preconditionFailure("Firestore did not provide a document ID")
        }
        return itemId
    }
    
    init(
        itemId: String,
        name: String,
        emoji: String,
        addedBy: String,
        price: Double,
        numberOfTheItem: Int = 1,
        category: String? = nil,
        isBought: Bool = false,
        dateCreated: Date = Date(),
        dateUpdated: Date? = nil
    ) {
        self.itemId = itemId
        self.name = name
        self.emoji = emoji
        self.addedBy = addedBy
        self.price = price
        self.numberOfTheItem = numberOfTheItem
        self.category = category
        self.isBought = isBought
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
}
