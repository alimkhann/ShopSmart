//
//  ShoppingListSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ShoppingListSheetViewModel: ObservableObject {
    let listId: String
    
    @Published var items: [ShoppingListItemModel] = []
    @Published var selectedIDs: Set<String> = []
    @Published var isLoading = false
    @Published var isAdding = false
    @Published var errorMessage: String?
    
    private let manager = ShoppingListsManager.shared
    
    init(listId: String) {
        self.listId = listId
    }
    
    func loadItems() async {
        isLoading = true; defer { isLoading = false }
        
        do {
            let fetched = try await manager.getItems(listId: listId)
            items = fetched
            debugPrint("✅ [\(Self.self)] loadItems succeeded: \(fetched.count) items")
        } catch {
            debugPrint("❌ [\(Self.self)] loadItems error:", error)
            errorMessage = "Could not load items: \(error.localizedDescription)"
        }
    }
    
    func addItem(
        name: String,
        emoji: String,
        count: Int,
        price: Double,
        category: String?
    ) async {
        isAdding = true; defer { isAdding = false }
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            var newItem = ShoppingListItemModel(
                itemId: "",
                name: name,
                emoji: emoji,
                addedBy: auth.userId,
                price: price,
                numberOfTheItem: count,
                category: category,
                isBought: false,
                dateCreated: Date(),
                dateUpdated: nil
            )
            let newID = try await manager.addItem(item: newItem, listId: listId)
            newItem.itemId = newID
            items.append(newItem)
            debugPrint("✅ [\(Self.self)] addItem: \(newID)")
        } catch {
            debugPrint("❌ [\(Self.self)] addItem error:", error)
            errorMessage = "Add failed: \(error.localizedDescription)"
        }
    }
    
    func updateItem(
        id: String,
        emoji: String,
        name: String,
        count: Int,
        price: Double,
        category: String?,
        isBought: Bool
    ) async {
        do {
            let data: [String: Any] = [
                "emoji": emoji,
                "name": name,
                "number_of_items": count,
                "price": price,
                "category": category as Any,
                "is_bought": isBought,
                "date_updated": FieldValue.serverTimestamp()
            ]
            try await manager.updateItem(itemId: id, listId: listId, data: data)
            if let idx = items.firstIndex(where: { $0.id == id }) {
                items[idx].emoji = emoji
                items[idx].name = name
                items[idx].numberOfTheItem = count
                items[idx].price = price
                items[idx].category = category
                items[idx].isBought = isBought
                items[idx].dateUpdated = Date()
            }
            debugPrint("✅ [\(Self.self)] updateItem: \(id)")
        } catch {
            debugPrint("❌ [\(Self.self)] updateItem error:", error)
            errorMessage = "Update failed: \(error.localizedDescription)"
        }
    }
    
    func deleteSelected() async {
        let toDelete = Array(selectedIDs)
        for id in toDelete {
            do {
                try await manager.deleteItem(itemId: id, listId: listId)
                items.removeAll { $0.id == id }
                selectedIDs.remove(id)
                debugPrint("✅ [\(Self.self)] deleteItem: \(id)")
            } catch {
                debugPrint("❌ [\(Self.self)] deleteSelected error:", error)
                errorMessage = "Delete failed: \(error.localizedDescription)"
            }
        }
    }
}

struct ShoppingListSheetView: View {
    @ObservedObject var rowVM: ShoppingListRowViewModel
    @StateObject private var vm: ShoppingListSheetViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditList = false
    @State private var showAddPopOver: Bool = false
    @State private var editTarget: ShoppingListItemModel?
    @State private var isSelecting = false
    
    init(rowVM: ShoppingListRowViewModel) {
        self.rowVM = rowVM
        _vm = StateObject(wrappedValue: ShoppingListSheetViewModel(listId: rowVM.listId))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text(rowVM.emoji)
                        .font(.largeTitle)
                    
                    Text(rowVM.name)
                        .font(.title2).bold()
                    
                    Spacer()
                    
                    HStack (spacing: 16) {
                        Button {
                            showAddPopOver = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        Button {
                            showEditList = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        Button(role: .destructive) {
                            if isSelecting {
                                if vm.selectedIDs.isEmpty {
                                    isSelecting = false
                                } else {
                                    Task {
                                        await vm.deleteSelected()
                                        isSelecting = false
                                    }
                                }
                            } else {
                                isSelecting = true
                            }
                        } label: {
                            Image(systemName: isSelecting ? "trash.fill" : "trash")
                                .resizable().frame(width: 24, height: 24)
                        }
                        .disabled(vm.items.isEmpty)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                Divider()
                
                List(selection: $vm.selectedIDs) {
                    ForEach(vm.items) { item in
                        HStack {
                            Text(item.emoji)
                            Text(item.name)
                            Spacer()
                            Text(String(format: "%.2f", item.price))
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelecting {} else {
                                editTarget = item
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .environment(\.editMode, .constant(isSelecting ? .active : .inactive))
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear { Task { await vm.loadItems() } }
            .errorAlert($vm.errorMessage)
            
            if showAddPopOver {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showAddPopOver = false }
                    }
                
                AddItemPopOverView(parent: vm, onCancel: {
                    withAnimation { showAddPopOver = false }
                })
                .frame(width: 300, height: 350)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
            
            if let item = editTarget {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { editTarget = nil }
                    }
                
                EditItemPopOverView(parent: vm, item: item, onCancel: {
                    withAnimation { editTarget = nil }
                })
                .frame(width: 300, height: 350)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showEditList) {
            EditShoppingListSheetView(
                listId: rowVM.listId,
                name: rowVM.name,
                emoji: rowVM.emoji
            ) {
                showEditList = false
                Task { await vm.loadItems() }
            }
            .presentationDetents([.fraction(0.35)])
        }
        .animation(.easeInOut, value: showAddPopOver)
        .animation(.easeInOut, value: editTarget)
    }
}
