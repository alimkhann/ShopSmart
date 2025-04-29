//
//  ShoppingListSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

@MainActor
final class ShoppingListSheetViewModel: ObservableObject {
    let listId: String
    @Published var items: [ShoppingListItemModel] = []
    let userId = try! AuthenticationManager.shared.getAuthenticatedUser().userId
    
    init(listId: String) {
        self.listId = listId
    }
    
    func loadItems() async {
        do {
            items = try await ShoppingListsManager.shared.getItems(listId: listId)
        } catch {
            print("Error loading items: \(error.localizedDescription)")
        }
    }
    
    func addItem() async throws {
        let newItem = ShoppingListItemModel(
            itemId: UUID().uuidString,
            name: "New Item",
            emoji: "🆕",
            addedBy: "\(userId)",
            price: 0.00,
            dateCreated: Date()
        )
        
        do {
            try await ShoppingListsManager.shared.addItem(item: newItem, listId: listId)
            items.append(newItem)
            try await ShoppingListsManager.shared.updateNumberOfItems(listId: listId, newNumberOfItems: items.count)
        } catch {
            print("Failed to add item: \(error.localizedDescription)")
        }
    }
}


struct ShoppingListSheetView: View {
    @ObservedObject var rowVM: ShoppingListRowViewModel
    @StateObject private var vm: ShoppingListSheetViewModel
    
    init(rowVM: ShoppingListRowViewModel) {
        self.rowVM = rowVM
        _vm = StateObject(wrappedValue: ShoppingListSheetViewModel(listId: rowVM.id))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Text(rowVM.emoji)
                        .font(.system(size: 36))
                    Text(rowVM.name)
                        .font(.title2.bold())
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vm.items) { item in
                            HStack(spacing: 12) {
                                Text(item.emoji)
                                    .font(.title3)
                                Text(item.name)
                                    .font(.body)
                                Spacer()
                                Text(String(format: "%.2f", item.price))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button {
                    Task {
                        try! await vm.addItem()
                    }
                } label: {
                    PrimaryButtonStyleView(content: "Add Item")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .task {
                await vm.loadItems()
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
