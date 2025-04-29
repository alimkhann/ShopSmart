//
//  CustomTextField.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.leading, 8)
        .frame(height: 44)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.placeholderText), lineWidth: 2)
        )
    }
}
