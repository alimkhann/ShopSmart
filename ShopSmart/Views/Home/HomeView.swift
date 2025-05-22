//
//  MainView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userVM = UserViewModel()
    @StateObject private var listsVM = ShoppingListsViewModel()
    
    @Binding var showAuthenticationView: Bool
    @State private var showProfileSettingsSheetView = false
    @State private var showCreateShoppingListSheetView = false
    @State private var searchText = ""
    
    @State private var isSelectingLists = false
    @State private var selectedListIDs: Set<String> = []
    @State private var selectedListRow: ShoppingListRowViewModel? = nil
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedListIDs) {
                Section {
                    ForEach(listsVM.lists) { list in
                        let rowVM = ShoppingListRowViewModel(model: list)
                        ShoppingListRowView(vm: rowVM)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isSelectingLists {} else {
                                    selectedListRow = rowVM
                                }
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(isSelectingLists ? .active : .inactive))
            .overlay(
                VStack {
                    Spacer()

                    HStack(spacing: 16) {
                        Spacer()

                        DeleteShoppingListsButtonView(
                            itemsExist: !listsVM.lists.isEmpty,
                            isSelecting: $isSelectingLists,
                            selectedIDs: $selectedListIDs
                        ) {
                            await listsVM.loadLists()
                        }

                        Button {
                            showCreateShoppingListSheetView = true
                        } label: {
                            CreateShoppingListButtonView()
                        }
                    }
                    .padding(.trailing)
                    .padding(.bottom, 24)
                }
            )
            .navigationTitle("🛒 ShopSmart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showProfileSettingsSheetView = true } label: {
                        profilePictureView
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer)
            .task {
                await userVM.loadCurrentUser()
                await listsVM.loadLists()
            }
            .errorAlert($listsVM.errorMessage)
            .errorAlert($userVM.errorMessage)
            .sheet(isPresented: $showCreateShoppingListSheetView, onDismiss: {
                Task { await listsVM.loadLists() }
            }) {
                CreateShoppingListSheetView()
                    .presentationDetents([.fraction(0.35)])
            }
            .sheet(isPresented: $showProfileSettingsSheetView, onDismiss: {
                Task { await userVM.loadCurrentUser() }
            }) {
                ProfileSettingsSheetView(showAuthenticationView: $showAuthenticationView)
                    .presentationDetents([.fraction(0.7), .large])
            }
            .fullScreenCover(isPresented: $showAuthenticationView) {
                NavigationStack {
                    AuthenticationView(showAuthenticationView: $showAuthenticationView)
                }
            }
            .sheet(item: $selectedListRow, onDismiss: {
                Task { await listsVM.loadLists() }
            }) { rowVM in
                ShoppingListSheetView(rowVM: rowVM)
                    .presentationDetents([.large, .medium])
            }
        }
    }
    
    @ViewBuilder
    private var profilePictureView: some View {
        if let photoUrl = userVM.user?.profileImagePathUrl,
           let url = URL(string: photoUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                case .failure(_):
                    placeholderImage
                case .empty:
                    ProgressView()
                        .frame(width: 32, height: 32)
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "person.crop.circle")
            .imageScale(.large)
            .foregroundStyle(Color.primary)
            .frame(width: 32, height: 32)
    }
}

#Preview {
    HomeView(showAuthenticationView: .constant(false))
}
