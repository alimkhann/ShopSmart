//
//  PrimaryButtonStyleView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

struct PrimaryButtonStyleView: View {
    let content: String
    
    var body: some View {
        Text(content)
            .foregroundStyle(.background)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.primary)
            .cornerRadius(8)
    }
}

struct SecondaryButtonStyleView: View {
    let content: String
    
    var body: some View {
        Text(content)
            .foregroundStyle(Color.primary)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, minHeight: 44)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 2)
            )
    }
}

struct CreateShoppingListButtonView: View {
    var body: some View {
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

#Preview {
    PrimaryButtonStyleView(content: "test")
    SecondaryButtonStyleView(content: "test")
    CreateShoppingListButtonView()
}
