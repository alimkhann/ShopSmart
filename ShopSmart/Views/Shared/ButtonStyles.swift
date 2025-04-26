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

#Preview {
    PrimaryButtonStyleView(content: "test")
}
