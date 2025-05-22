//
//  EditShoppingListSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import SwiftUI

struct EditShoppingListSheetView: View {
    @StateObject private var viewModel: EditShoppingListSheetViewModel

    let onDone: () -> Void
    init(
        listId: String,
        name: String,
        emoji: String,
        onDone: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EditShoppingListSheetViewModel(
                listId: listId,
                currentName: name,
                currentEmoji: emoji
            )
        )
        self.onDone = onDone
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("🛍️", text: $viewModel.pendingEmoji)
                        .frame(width: 44, height: 44)
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.placeholderText), lineWidth: 2)
                        )
                    
                    CustomTextField(
                        placeholder: "shopping list name",
                        text: $viewModel.pendingName
                    )
                }
                
                Button {
                    Task {
                        let success = await viewModel.updateList()
                        if success {
                            await MainActor.run {
                                onDone()
                            }
                        }
                    }
                } label: {
                    if viewModel.isUpdating {
                        ProgressView().tint(.white)
                    }
                    Text("Edit List")
                }
                .disabled(!viewModel.canUpdate)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(viewModel.canUpdate ? Color.primary : Color.gray)
                .foregroundStyle(.background)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationTitle("Edit List")
            .errorAlert($viewModel.errorMessage)
            .padding(.top, 36)
            .padding(.horizontal, 24)
        }
    }
}
