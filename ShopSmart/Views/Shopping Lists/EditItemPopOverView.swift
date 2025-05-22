//
//  AddItemPopOverView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 21/5/2025.
//

import SwiftUI



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
