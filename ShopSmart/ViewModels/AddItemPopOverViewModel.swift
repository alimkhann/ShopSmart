//
//  AddItemPopOverViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import Foundation

@MainActor
final class AddItemPopOverViewModel : ObservableObject {
    @Published var emoji: String = ""
    @Published var name: String = ""
    @Published var numberOfTheItem: String = "1"
    @Published var priceText: String = ""
    @Published var category: String = ""
    
    @Published var isAdding: Bool = false
    @Published var errorMessage: String?
    
    var intCount: Int? { Int(numberOfTheItem) }
    var price: Double? { Double(priceText) }
    var totalPrice: Double? {
        guard let count = intCount, let price = price, count > 1 else { return nil }
        return price * Double(count)
    }
    var canAdd : Bool {
        emoji.count == 1 &&
        (emoji.first?.isEmoji ?? false) &&
        !name.isEmpty &&
        intCount != nil &&
        price != nil
    }
    
    private let parent: ShoppingListSheetViewModel
    
    init(parent: ShoppingListSheetViewModel) {
        self.parent = parent
    }
    
    func addItem() async {
        guard canAdd else { return }
        isAdding = true; defer { isAdding = false }
        await parent.addItem(
            name: name,
            emoji: emoji,
            count: intCount!,
            price: price!,
            category: category.isEmpty ? nil : category
        )
        debugPrint("✅ [AddItemPopoverViewModel] item added: \(emoji) \(name)")
        if parent.errorMessage != nil {
            self.errorMessage = parent.errorMessage
        }
    }
}
