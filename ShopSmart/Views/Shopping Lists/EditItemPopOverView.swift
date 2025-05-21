//
//  AddItemPopOverView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 21/5/2025.
//

import SwiftUI

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

struct EditItemPopOverView: View {
    @StateObject private var viewModel: EditItemPopOverViewModel
    let onCancel: ()->Void
    
    init(parent: ShoppingListSheetViewModel, item: ShoppingListItemModel, onCancel: @escaping ()->Void) {
        _viewModel = StateObject(wrappedValue: EditItemPopOverViewModel(parent: parent, item: item))
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack (spacing: 12) {
            HStack {
                TextField("🍎", text: $viewModel.emoji)
                    .frame(width: 44, height: 44)
                    .multilineTextAlignment(.center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.placeholderText), lineWidth: 2)
                    )
                
                CustomTextField(placeholder: "Name", text: $viewModel.name)
            }
            
            HStack {
                CustomTextField(placeholder: "Count", text: $viewModel.numberOfTheItem)
                    .keyboardType(.numberPad)
                
                CustomTextField(placeholder: "Price", text: $viewModel.priceText)
                    .keyboardType(.decimalPad)
            }
            
            if let total = viewModel.totalPrice {
                Text("Total: \(String(format: "%.2f", total))")
            }
            
            CustomTextField(placeholder: "Category", text: $viewModel.category)
            
            HStack {
                Button {
                    onCancel()
                } label: {
                    SecondaryButtonStyleView(content: "Cancel")
                }
                
                Spacer()
                
                Button {
                    Task {
                        await viewModel.updateItem()
                        if viewModel.errorMessage == nil { onCancel() }
                    }
                } label: {
                    if viewModel.isUpdating {
                        ProgressView().tint(.white)
                    } else {
                        PrimaryButtonStyleView(content: "Edit Item")
                    }
                }
                .disabled(!viewModel.canUpdate)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(viewModel.canUpdate ? Color.primary : Color.gray)
                .foregroundStyle(.background)
                .cornerRadius(8)
            }
        }
        .padding(12)
        .frame(width: 300, height: 350)
    }
}
