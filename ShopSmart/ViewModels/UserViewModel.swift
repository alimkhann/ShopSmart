//
//  UserViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 29/4/2025.
//

import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        isLoading = true; defer { isLoading = false }
        
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: auth.userId)
            debugPrint("✅ [\(Self.self)] loaded user: \(auth.userId)")
        } catch {
            debugPrint("❌ [\(Self.self)] loadCurrentUser error:", error)
            errorMessage = "Load Current User Failed: \(error.localizedDescription)"
        }
    }
}
