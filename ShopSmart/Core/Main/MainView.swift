//
//  MainView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    
    func loadCurrentUser() async {
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: auth.userId)
        } catch {
            print("Load user failed: \(error)")
        }
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var searchText = ""
    @Binding var showAuthenticationView: Bool
    @State private var showProfileSettingsSheetView = false
    @State private var showShoppingListSheetView = false
    @State private var showCreateShoppingListSheetView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<5) { _ in
                            ShoppingListView()
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Button {
                    showCreateShoppingListSheetView = true
                } label: {
                    CreateShoppingListButtonView()
                }
            }
            .task {
                await viewModel.loadCurrentUser()
            }
            .navigationTitle("🛒 ShopSmart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileSettingsSheetView = true
                    }) {
                        profilePictureView
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer)
            .sheet(
                isPresented: $showProfileSettingsSheetView,
                onDismiss: {
                    Task { await viewModel.loadCurrentUser() }
                }
            ) {
                ProfileSettingsSheetView(showAuthenticationView: $showAuthenticationView)
                    .presentationDetents([.fraction(0.7), .large])
            }
            .fullScreenCover(isPresented: $showAuthenticationView) {
                NavigationStack {
                    AuthenticationView(showAuthenticationView: $showAuthenticationView)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private var profilePictureView: some View {
        if let photoUrl = viewModel.user?.profileImagePathUrl,
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
    MainView(showAuthenticationView: .constant(false))
}
