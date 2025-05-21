//
//  View+ErrorAlert.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 30/4/2025.
//

import SwiftUI

extension View {
    func errorAlert(_ errorMessage: Binding<String?>) -> some View {
        alert("Error", isPresented: .init(
            get: { errorMessage.wrappedValue != nil },
            set: { if !$0 { errorMessage.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage.wrappedValue = nil }
        } message: {
            Text(errorMessage.wrappedValue ?? "")
        }
    }
}
