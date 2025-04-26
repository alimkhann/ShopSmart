//
//  ProfileSheetView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct ProfileSettingsSheetView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                Button("Log Out", role: .destructive) {
                    authVM.signOut()
                }
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, minHeight: 44)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.red, lineWidth: 2)
                )
            }
            .navigationBarTitle("Profile Settings")
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
    }
}




#Preview {
    ProfileSettingsSheetView()
}
