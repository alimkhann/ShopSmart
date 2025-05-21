//
//  AddItemPopOverView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 21/5/2025.
//

import SwiftUI

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

struct AddItemPopOverView: View {
    @StateObject private var viewModel: AddItemPopOverViewModel
    let onCancel: ()->Void
    
    init(parent: ShoppingListSheetViewModel, onCancel: @escaping ()->Void) {
        _viewModel = StateObject(wrappedValue: AddItemPopOverViewModel(parent: parent))
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
                
                CustomTextField(placeholder: "New item name", text: $viewModel.name)
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
                        await viewModel.addItem()
                        if viewModel.errorMessage == nil { onCancel() }
                    }
                } label: {
                    if viewModel.isAdding {
                        ProgressView().tint(.white)
                    } else {
                        PrimaryButtonStyleView(content: "Add Item")
                    }
                }
                .disabled(!viewModel.canAdd)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(viewModel.canAdd ? Color.primary : Color.gray)
                .foregroundStyle(.background)
                .cornerRadius(8)
            }
        }
        .padding(12)
    }
}
