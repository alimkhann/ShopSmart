//
//  DeleteShoppingListsButtonView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 22/5/2025.
//

import SwiftUI

struct DeleteShoppingListsButtonView: View {
  let itemsExist: Bool
  @Binding var isSelecting: Bool
  @Binding var selectedIDs: Set<String>
  let onDeleteComplete: () async -> Void

  var body: some View {
    if itemsExist {
      Button {
        if isSelecting {
          if selectedIDs.isEmpty {
            isSelecting = false
          } else {
            Task {
              for id in selectedIDs {
                try? await ShoppingListsManager.shared.deleteList(listId: id)
              }
              selectedIDs.removeAll()
              isSelecting = false
              await onDeleteComplete()
            }
          }
        } else {
          isSelecting = true
        }
      } label: {
        Image(systemName: isSelecting ? "trash.fill" : "trash")
          .padding()
          .background(Color.red.opacity(0.8))
          .foregroundColor(.white)
          .clipShape(Circle())
          .shadow(radius: 4)
      }
    }
  }
}
