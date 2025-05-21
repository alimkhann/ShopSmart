//
//  ShoppingListRowViewModel.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 29/4/2025.
//

import Foundation

@MainActor
final class ShoppingListRowViewModel: ObservableObject, Identifiable {
    let listId: String
    @Published var emoji: String
    @Published var name: String
    @Published var date: Date?
    @Published var nOfItems: Int
    @Published var collaboratorAvatars: [URL] = []
    @Published var errorMessage: String?
    
    private let collaborators: [String]
    private let userManager = UserManager.shared
    
    init(model: ShoppingListModel) {
        self.listId = model.listId!
        self.emoji = model.emoji
        self.name = model.name
        self.date = model.dateCreated
        self.nOfItems = model.numberOfItems
        self.collaborators = model.collaborators
//        loadAvatars()
        debugPrint("✅ [\(Self.self)] init with list \(listId)")
    }
    
//    private func loadAvatars() {
//        Task {
//            var urls: [URL] = []
//            for uid in collaborators {
//                do {
//                    let user = try await userManager.getUser(userId: uid)
//                    if let s = user.profileImagePathUrl, let url = URL(string: s) {
//                        urls.append(url)
//                    }
//                } catch {
//                    print("Avatar load failed for \(uid): \(error)")
//                }
//            }
//            self.collaboratorAvatars = urls
//        }
//    }
}
