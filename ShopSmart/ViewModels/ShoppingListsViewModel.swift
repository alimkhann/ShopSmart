//
//  ShoppingListsViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 29/4/2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class ShoppingListsViewModel: ObservableObject {
    @Published var lists: [ShoppingListModel] = []
    @Published var errorMessage: String?
    private let manager = ShoppingListsManager.shared
    
    func loadLists() async {
        let auth = try? AuthenticationManager.shared.getAuthenticatedUser()
        guard let userId = auth?.userId else { return }
        
        do {
            let fetchedLists = try await manager.getLists(for: userId)
            self.lists = fetchedLists
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
