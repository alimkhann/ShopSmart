//
//  ShoppingListItemModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 29/4/2025.
//

import Foundation
import FirebaseFirestore

struct ShoppingListItemModel: Codable, Identifiable {
    @DocumentID var id: String?
    let itemId: String
    var name: String
    var emoji: String
    var addedBy: String
    var price: Double
    var numberOfItems: Int
    var category: String?
    var isBought: Bool = false
    let dateCreated: Date?
    let dateUpdated: Date?
    
    init(
        itemId: String,
        name: String,
        emoji: String,
        addedBy: String,
        price: Double,
        numberOfItems: Int = 1,
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
        self.numberOfItems = numberOfItems
        self.category = category
        self.isBought = isBought
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
    }
}
