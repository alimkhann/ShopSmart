//
//  MainView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 25/4/2025.
//

import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    @Published var user: AuthDataResultModel?
    
    init() {
        loadUser()
    }
    
    private func loadUser() {
        do {
            self.user = try AuthenticationManager.shared.getAuthenticatedUser()
        } catch {
            print("Error loading user: \(error)")
        }
    }
}

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @Binding var showAuthenticationView: Bool
    @State private var searchText = ""
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
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 64, height: 64)
                            .background(Color.primary)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 0)
                        
                        Image(systemName: "plus")
                            .foregroundStyle(.background)
                            .frame(width: 48, height: 48)
                    }
                    .frame(width: 64, height: 64)
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("🛒 ShopSmart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileSettingsSheetView = true
                    }) {
                        if let photoUrl = viewModel.user?.photoUrl, let url = URL(string: photoUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle")
                                .imageScale(.large)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer)
            .sheet(isPresented: $showProfileSettingsSheetView) {
                ProfileSettingsSheetView(showAuthenticationView: $showAuthenticationView)
                    .presentationDetents([.fraction(0.4)])
            }
            .fullScreenCover(isPresented: $showAuthenticationView) {
                NavigationStack {
                    AuthenticationView(showAuthenticationView: $showAuthenticationView)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    MainView(showAuthenticationView: .constant(false))
}
