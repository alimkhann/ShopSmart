//
//  CreateShoppingListSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 28/4/2025.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class CreateShoppingListSheetViewModel: ObservableObject {
    @Published private(set) var list: ShoppingListModel? = nil
    @Published var pendingEmoji = ""
    @Published var pendingName = ""
    @Published var isCreating = false
    @Published var validationError: String?
    
    var canCreate: Bool {
        !pendingName.isEmpty && pendingEmoji.count == 1
    }
    
    @MainActor
    func createList() async -> Bool {
        let name  = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let emoji = pendingEmoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            validationError = "Please enter a name for your shopping list."
            return false
        }
        guard emoji.count == 1 else {
            validationError = "Emoji must be exactly one character."
            return false
        }
        guard let auth = try? AuthenticationManager.shared.getAuthenticatedUser() else {
            validationError = "Authentication error. Please sign in again."
            return false
        }
        
        let newList = ShoppingListModel(
            name: name,
            emoji: emoji,
            ownerId: auth.userId,
            collaborators: [auth.userId]
        )
        
        isCreating = true
        defer { isCreating = false }
        
        do {
            try Firestore.firestore()
                .collection("lists")
                .addDocument(from: newList)
            
            pendingName = ""
            pendingEmoji = ""
            return true
        } catch {
            validationError = "Unable to create list: \(error.localizedDescription)"
            return false
        }
    }
}

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
            .padding(.top, 36)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    CreateShoppingListSheetView()
}
