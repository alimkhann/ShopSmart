//
//  ShoppingListSheInvalid frame dimension (negative or non-finite).etView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

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
