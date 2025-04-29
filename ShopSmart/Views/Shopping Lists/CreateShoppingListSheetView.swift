//
//  CreateShoppingListSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import SwiftUI

struct CreateShoppingListSheetView: View {
    @StateObject private var viewModel = CreateShoppingListSheetViewModel()
    @Environment(\.dismiss) var dismiss
    
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
                        let success = await viewModel.createList()
                        if success {
                            await MainActor.run {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    if viewModel.isCreating {
                        ProgressView().tint(.white)
                    }
                    Text("Create A List")
                }
                .disabled(!viewModel.canCreate)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(viewModel.canCreate ? Color.primary : Color.gray)
                .foregroundStyle(.background)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationTitle("Create A List")
            .padding(.top, 36)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    CreateShoppingListSheetView()
}
