//
//  ProfileSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct ProfileSettingsSheetView: View {
    @StateObject private var viewModel = ProfileSettingsSheetViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @Binding var showAuthenticationView: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    avatarView
                }
                .onChange(of: selectedItem) {
                    if let item = selectedItem {
                        Task { await viewModel.imagePicked(item) }
                    }
                }
                
                if viewModel.user?.profileImagePath != nil {
                    Button("Delete Image", role: .destructive) {
                        Task { await viewModel.deleteProfileImage() }
                    }
                }
                
                CustomTextField(
                    placeholder: "username",
                    text: Binding(
                        get: { viewModel.pendingUsername ?? viewModel.user?.username ?? "" },
                        set: { viewModel.pendingUsername = $0 }
                    )
                )
                
                Button {
                    Task { await viewModel.saveAllChanges() }
                } label: {
                    if viewModel.isUpdating || viewModel.isUploadingImage {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save Changes")
                    }
                }
                .disabled(!viewModel.canSaveAll)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(viewModel.canSaveAll ? Color.primary : Color.gray)
                .foregroundStyle(.background)
                .cornerRadius(8)
                
                Button {
                    Task {
                        do {
                            try viewModel.logOut()
                            dismiss()
                            showAuthenticationView = true
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    SecondaryButtonStyleView(content: "Log Out")
                }
                
                Button("Delete Account", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            dismiss()
                            showAuthenticationView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 2))
                
                Spacer()
            }
            .padding()
            .task { await viewModel.loadCurrentUser() }
            .navigationTitle("Profile Settings")
        }
    }
    
    @ViewBuilder
    private var avatarView: some View {
        Group {
            if let data = viewModel.pendingImageData, let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable()
            } else if let urlString = viewModel.user?.profileImagePathUrl,
                      let url = URL(string: urlString) {
                AsyncImage(url: url) { img in img.resizable() } placeholder: { ProgressView() }
            } else {
                Image(systemName: "person.crop.circle.fill").resizable().foregroundStyle(.gray)
            }
        }
        .scaledToFill()
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .contentShape(Circle())
    }
}

#Preview {
    ProfileSettingsSheetView(showAuthenticationView: .constant(false))
}
