//
//  ShoppingListView.swift
//  ShopSmart
//
//  Created by Alimkhan Yergebayev on 26/4/2025.
//

import SwiftUI

struct ShoppingListView: View {
    var emoji: String = "🛒"
    var name: String = "Shopping List"
    var date: Date = Date()
    var nOfItems: Int = 7
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 36))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 17, weight: .semibold))
                
                HStack(alignment: .center, spacing: 4) {
                    Text(dateFormatter.string(from: date))
                        .font(.system(size: 12))
                    
                    Text("•")
                        .font(.system(size: 12))
                    
                    Text("\(nOfItems) items")
                        .font(.system(size: 12))
                    
                    Text("•")
                        .font(.system(size: 12))
                    
                    HStack(alignment: .center, spacing: -8) {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.red)
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.green)
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .padding(0)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.primary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(red: 0.94, green: 0.94, blue: 0.94).opacity(0.5))
                .cornerRadius(4)
            }
        }
        .padding(.leading, 4)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .frame(width: 370, alignment: .leading)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.25)
                .stroke(Color(red: 0.94, green: 0.94, blue: 0.94), lineWidth: 01)
            
        )
    }
}

#Preview {
    ShoppingListView()
}
