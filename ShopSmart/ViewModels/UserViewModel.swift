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
    @Published var errorMessage: String?

    func loadCurrentUser() async {
        do {
            let auth = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: auth.userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
