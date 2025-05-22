//
//  EditItemPopOverViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import Foundation

@MainActor
final class EditItemPopOverViewModel : ObservableObject {
    @Published var emoji: String
    @Published var name: String
    @Published var numberOfTheItem: String
    @Published var priceText: String
    @Published var category: String
    @Published var isBought: Bool
    
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String?
    
    var intCount: Int? { Int(numberOfTheItem) }
    var price: Double? { Double(priceText) }
    var totalPrice: Double? {
        guard let count = intCount, let price = price, count > 1 else { return nil }
        return price * Double(count)
    }
    var canUpdate : Bool {
        emoji.count == 1 &&
        (emoji.first?.isEmoji ?? false) &&
        !name.isEmpty &&
        intCount != nil &&
        price != nil
    }
    
    private let parent: ShoppingListSheetViewModel
    private let original: ShoppingListItemModel
    
    init(parent: ShoppingListSheetViewModel, item: ShoppingListItemModel) {
        self.parent = parent
        self.original = item
        self.emoji = item.emoji
        self.name = item.name
        self.numberOfTheItem = String(item.numberOfTheItem)
        self.priceText = String(item.price)
        self.category = item.category ?? ""
        self.isBought = item.isBought
    }
    
    func updateItem() async {
        guard canUpdate else { return }
        isUpdating = true
        defer { isUpdating = false }
        await parent.updateItem(
            id: original.id,
            emoji: emoji,
            name: name,
            count: intCount!,
            price: price!,
            category: category.isEmpty ? nil : category,
            isBought: isBought
        )
        debugPrint("✅ [AddItemPopoverViewModel] item added: \(emoji) \(name)")
        if parent.errorMessage != nil {
            self.errorMessage = parent.errorMessage
        }
    }
}
